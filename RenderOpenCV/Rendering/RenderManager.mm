//
//  RenderManager.m
//  RenderOpenCV
//
//  Created by Anastasia Tarasova on 24/05/16.
//  Copyright © 2016 Anastasia Tarasova. All rights reserved.
//

#import "RenderManager.h"
//#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
//#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/EAGL.h>
#import <iostream>



@interface RenderManager(){
    
    // The OpenGL ES names for the framebuffer and renderbuffer used for rendering.
    GLuint  frameBuffer;
    GLuint  colorRenderbuffer,
            depthRenderbuffer;
    
    EAGLContext *context;

    // The texture we're going to render to
    GLuint renderedTexture;
}

@end

@implementation RenderManager

-(instancetype)initWithCalibration:(CameraCalibration)calibration{

    self = [super init];
    if (self) {
        
       [self initContext];
        
        width = 640;
        height = 480;
        
        glEnable(GL_TEXTURE_2D);
        glGenTextures(1, &renderedTexture);
        // "Bind" the newly created texture : all future texture functions will modify this texture
        glBindTexture(GL_TEXTURE_2D, renderedTexture);
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
  
        
        glEnable(GL_DEPTH_TEST);
        m_calibration = calibration;
        
      
        
    }
    
    return self;
}



-(void)createFrameBuffers{

    if (context && !frameBuffer){
        
        [EAGLContext setCurrentContext:context];
        
        //1.Create the framebuffer and bind it.
        glGenFramebuffers(1, &frameBuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
        
        //2.Create a depth or depth/stencil renderbuffer, allocate storage for it, and attach it to the framebuffer’s depth attachment point.
       
        glGenRenderbuffers(1, &depthRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
        
        //3.Test the framebuffer for completeness. This test only needs to be performed when the framebuffer’s configuration changes.
        GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER) ;
        if(status != GL_FRAMEBUFFER_COMPLETE) {
            NSLog(@"failed to make complete framebuffer object %x", status);
        }
    }
}


- (void)deleteFramebuffer
{
    if (context)
    {
        [EAGLContext setCurrentContext:context];
        
        if (frameBuffer) {
            glDeleteFramebuffers(1, &frameBuffer);
            frameBuffer = 0;
        }
        
        if (colorRenderbuffer) {
            glDeleteRenderbuffers(1, &colorRenderbuffer);
            colorRenderbuffer = 0;
        }
        
        if (depthRenderbuffer) {
            glDeleteRenderbuffers(1, &depthRenderbuffer);
            depthRenderbuffer = 0;
        }
        NSLog(@"Framebuffer deleted");
        
    }
}

- (void)setFramebuffer
{
    if (context) {
        [EAGLContext setCurrentContext:context];
        
        if (!frameBuffer)
            [self createFrameBuffers];
        
        glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
        
        glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
        glViewport(0, 0, width, height);
        
        glClear(GL_DEPTH_BUFFER_BIT| GL_COLOR_BUFFER_BIT);
        
        
    }
}

- (void)setContext:(EAGLContext *)newContext
{
    if (context != newContext)
    {
        [self deleteFramebuffer];
        
        context = newContext;
        
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)initContext
{
    EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!aContext)
        NSLog(@"Failed to create ES context");
    else if (![EAGLContext setCurrentContext:aContext])
        NSLog(@"Failed to set ES context current");
    
    [self setContext:aContext];
    //[self setFramebuffer];
}

#pragma mark - Augmented reality rendering
- (void)buildProjectionMatrix:(Matrix33)cameraMatrix width:(int)screen_width height:(int)screen_height projection:(Matrix44&) projectionMatrix
{
    float near = 0.01;  // Near clipping distance
    float far  = 100;  // Far clipping distance
    
    // Camera parameters
    float f_x = cameraMatrix.data[0]; // Focal length in x axis
    float f_y = cameraMatrix.data[4]; // Focal length in y axis (usually the same?)
    float c_x = cameraMatrix.data[2]; // Camera primary point x
    float c_y = cameraMatrix.data[5]; // Camera primary point y
    
    projectionMatrix.data[0] = - 2.0 * f_x / screen_width;
    projectionMatrix.data[1] = 0.0;
    projectionMatrix.data[2] = 0.0;
    projectionMatrix.data[3] = 0.0;
    
    projectionMatrix.data[4] = 0.0;
    projectionMatrix.data[5] = 2.0 * f_y / screen_height;
    projectionMatrix.data[6] = 0.0;
    projectionMatrix.data[7] = 0.0;
    
    projectionMatrix.data[8] = 2.0 * c_x / screen_width - 1.0;
    projectionMatrix.data[9] = 2.0 * c_y / screen_height - 1.0;
    projectionMatrix.data[10] = -( far+near ) / ( far - near );
    projectionMatrix.data[11] = -1.0;
    
    projectionMatrix.data[12] = 0.0;
    projectionMatrix.data[13] = 0.0;
    projectionMatrix.data[14] = -2.0 * far * near / ( far - near );
    projectionMatrix.data[15] = 0.0;
}



/*- (void) drawBackground
{
    GLfloat w = width;
    GLfloat h = height;
    
    const GLfloat squareVertices[] =
    {
        0, 0,
        w, 0,
        0, h,
        w, h
    };
    
    static const GLfloat textureVertices[] =
    {
        1, 0,
        1, 1,
        0, 0,
        0, 1
    };
    
    static const GLfloat proj[] =
    {
        0, -2.f/w, 0, 0,
        -2.f/h, 0, 0, 0,
        0, 0, 1, 0,
        1, 1, 0, 1
    };
    
    int glErCode = glGetError();
    
    glMatrixMode(GL_PROJECTION);
    
    
    glErCode = glGetError();
    
    glLoadMatrixf(proj);
    
    glErCode = glGetError();
    
    //glMatrixMode(GL_MODELVIEW);
    //glLoadIdentity();
    
    
    glErCode = glGetError();
    
    glDepthMask(FALSE);
    //glDisable(GL_COLOR_MATERIAL);
    
    glErCode = glGetError();
    
    glEnable(GL_TEXTURE_2D);
    
    glErCode = glGetError();
    
    glBindTexture(GL_TEXTURE_2D, renderedTexture);
    
    glErCode = glGetError();
    
    // Update attribute values.
   // glVertexPointer(2, GL_FLOAT, 0, squareVertices);
    //glEnableClientState(GL_VERTEX_ARRAY);
    //glTexCoordPointer(2, GL_FLOAT, 0, textureVertices);
    //glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    //glColor4f(1,1,1,1);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    //glDisableClientState(GL_VERTEX_ARRAY);
   // glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisable(GL_TEXTURE_2D);
    
    glErCode = glGetError();
}

-(void)drawAR:(cv::Mat&)frame {

    
    //from marker detector
    
    //draw cube
    //build projection matrix
    Matrix44 projectionMatrix;
    [self buildProjectionMatrix:m_calibration.getIntrinsic() width:width height:height projection:projectionMatrix];
    
    
   // glMatrixMode(GL_PROJECTION);//говорит о том, что команды относятся к проекту.
    glLoadMatrixf(projectionMatrix.data);
    
    glMatrixMode(GL_MODELVIEW);//говорит о том, что работы будет теперь просмотром, а не проектом. Это важно. Дело в том , что проект и просмотр имеют разницу. Зачастую необходимо поворачивать фигуры друг относительно друга и т.п. это делается в разных матрицах и т.д.
    glLoadIdentity();//считывает текущую матрицу.
    
    glDepthMask(TRUE);
    glEnable(GL_DEPTH_TEST);
    //glDepthFunc(GL_LESS);
    //glDepthFunc(GL_GREATER);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_NORMAL_ARRAY);
    
    glPushMatrix();
    glLineWidth(3.0f);
    
    float lineX[] = {0,0,0,1,0,0};
    float lineY[] = {0,0,0,0,1,0};
    float lineZ[] = {0,0,0,0,0,1};
    
    const GLfloat squareVertices[] = {
        -0.5f, -0.5f,
        0.5f,  -0.5f,
        -0.5f,  0.5f,
        0.5f,   0.5f,
    };
    const GLubyte squareColors[] = {
        255, 255,   0, 255,
        0,   255, 255, 255,
        0,     0,   0,   0,
        255,   0, 255, 255,
    };
    
    for (size_t transformationIndex=0; transformationIndex<m_transformations.size(); transformationIndex++)
    {
        const Transformation& transformation = m_transformations[transformationIndex];
        
        Matrix44 glMatrix = transformation.getMat44();
        
        glLoadMatrixf(reinterpret_cast<const GLfloat*>(&glMatrix.data[0]));
        
        // draw data
        glVertexPointer(2, GL_FLOAT, 0, squareVertices);
        glEnableClientState(GL_VERTEX_ARRAY);
        glColorPointer(4, GL_UNSIGNED_BYTE, 0, squareColors);
        glEnableClientState(GL_COLOR_ARRAY);
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        glDisableClientState(GL_COLOR_ARRAY);
        
        float scale = 0.5;
        glScalef(scale, scale, scale);
        
        glTranslatef(0, 0, 0.1f);
        
        glColor4f(1.0f, 0.0f, 0.0f, 1.0f);
        glVertexPointer(3, GL_FLOAT, 0, lineX);
        glDrawArrays(GL_LINES, 0, 2);
        
        glColor4f(0.0f, 1.0f, 0.0f, 1.0f);
        glVertexPointer(3, GL_FLOAT, 0, lineY);
        glDrawArrays(GL_LINES, 0, 2);
        
        glColor4f(0.0f, 0.0f, 1.0f, 1.0f);
        glVertexPointer(3, GL_FLOAT, 0, lineZ);
        glDrawArrays(GL_LINES, 0, 2);
    }
    
    glPopMatrix();
    glDisableClientState(GL_VERTEX_ARRAY);
    
}*/

- (void)drawFrame:(cv::Mat&)frame withTransformations:(const std::vector<Transformation>&)transformations
{
    
    m_transformations = transformations;
 
    [self CVMat2GLTexture:frame];
    
    int glErCode = glGetError();
    // Draw a video on the background
    //[self drawBackground];
    
    
    // Draw 3D objects on the position of the detected markers
    //[self drawAR:frame];
    

   
    //result to cvMat
    //[self GLTexture2CVMat:frame];
}

//here we convert cvMat to OpenGL Texture
-(void) CVMat2GLTexture:(cv::Mat&)image
{
    
    /*width = image.cols;
    height = image.rows;
    
    cv::flip(image, image, 0);
    
    [self setFramebuffer];
    
    glEnable(GL_TEXTURE_2D);
    
   
    glGenTextures(1, &renderedTexture);
    // "Bind" the newly created texture : all future texture functions will modify this texture
    glBindTexture(GL_TEXTURE_2D, renderedTexture);
    

    
    int glErCode = glGetError();
    //glTexEnvf( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
    
    glErCode = glGetError();
    glPixelStorei(GL_PACK_ALIGNMENT, 4);
    
    //cv::cvtColor(image, image, CV_BGRA2RGBA);
    
    glTexImage2D(GL_TEXTURE_2D,
                 0,
                 GL_RGBA,
                 width,
                 height,
                 0,
                 GL_BGRA,
                 GL_UNSIGNED_BYTE,
                 image.data);
    
    
    
    glErCode = glGetError();
    
    if (glErCode != GL_NO_ERROR)
    {
        std::cout << glErCode << std::endl;
    }
    
    
    // Set "renderedTexture" as our colour attachement #0
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,GL_TEXTURE_2D,renderedTexture, 0);
    
    
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    glViewport(0, 0, width, height);
    
    glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
    
    glErCode = glGetError();
    if (glErCode != GL_NO_ERROR)
    {
        std::cout << glErCode << std::endl;
    }
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    int status = glCheckFramebufferStatus(GL_FRAMEBUFFER) ;
    if(status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"failed to make complete framebuffer object %x", status);
    }
    
    */
    
    width = image.cols;
    height = image.rows;
    
    //cv::flip(image, image, 0);
    
    [self setFramebuffer];
    
    glEnable(GL_TEXTURE_2D);
    
    
    glGenTextures(1, &renderedTexture);
    // "Bind" the newly created texture : all future texture functions will modify this texture
    glBindTexture(GL_TEXTURE_2D, renderedTexture);
    int glErCode = glGetError();
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glPixelStorei(GL_PACK_ALIGNMENT, 1);
    
    glTexImage2D(GL_TEXTURE_2D,
                 0,
                 GL_RGBA,
                 width,
                 height,
                 0,
                 GL_BGRA,
                 GL_UNSIGNED_BYTE,
                 image.ptr());
    
    
    glErCode = glGetError();
    
    if (glErCode != GL_NO_ERROR)
    {
        std::cout << glErCode << std::endl;
    }

    // Set "renderedTexture" as our colour attachement #0
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,GL_TEXTURE_2D,renderedTexture, 0);
    
    
    
    glErCode = glGetError();
    if (glErCode != GL_NO_ERROR)
    {
        std::cout << glErCode << std::endl;
    }
    
    
    int status = glCheckFramebufferStatus(GL_FRAMEBUFFER) ;
    if(status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"failed to make complete framebuffer object %x", status);
    }
    
    
    GLuint bufferLength = width * height *4 *sizeof(GLubyte);
    GLubyte* buffer =(GLubyte*)malloc(bufferLength);
    
    glPixelStorei ( GL_UNPACK_ALIGNMENT , 1 ) ;
    
    glBindFramebuffer(GL_FRAMEBUFFER, 1);
    
    glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
    
    
    glErCode = glGetError();
    
    cv::Mat tmp(height, width, CV_8UC4, buffer);
    
    
    
    
    
    //bool zeros = tmp.empty();
    //zeros = image.empty();
    cv::flip(image, image, 0);
    
    image = tmp.clone();
    
    glDeleteTextures(1, &renderedTexture );
    
    free(buffer);
    
}



/*I think no need to create a new cvMat since we have current frame*/
-(void)GLTexture2CVMat:(cv::Mat&)frame{
    
    
    GLuint bufferLength = width * height *4;
    GLubyte* buffer =(GLubyte*)malloc(bufferLength);
    
    
    
    glPixelStorei ( GL_UNPACK_ALIGNMENT , 4 ) ;
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    
    int status = glCheckFramebufferStatus(GL_FRAMEBUFFER) ;
    if(status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"failed to make complete framebuffer object %x", status);
    }
    
    glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
    
    cv::Mat tmp(height, width, CV_8UC4, buffer);
    
    cv::flip(tmp, tmp, 0);
    cv::cvtColor(tmp, tmp, CV_RGBA2BGRA);
    
    
    frame = tmp.clone();
    
    glDeleteTextures(1, &renderedTexture );
    
    int glErCode = glGetError();
    if (glErCode != GL_NO_ERROR)
    {
        std::cout << glErCode << std::endl;
    }
    
    free(buffer);
   
}

@end
