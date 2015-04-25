//
//  ViewController.m
//  SolarSystem
//
//  Created by Ryan Martin on 2015-03-14. Student number: 201039054. Login: rtm773.
//  Copyright (c) 2015 Ryan Martin. All rights reserved.
//
// This program mimics the inner solar system planets with rotation speeds, relative sizes
// (exlcuding the sun) and distances between planets.
// Several modules were taken from the Week 10 lab in order to draw and bind textures and
// shapes. Pinch gesture recognition is working, however the touch (tap on a planet) is currently
// not. In future iterations, this would be implemented and tested to work with touch screen devices.
// Internal documentation is provided below for any extra clarification.
//

#import "ViewController.h"
#import "SphereModel.h"
#import "ImageTexture.h"

@interface ViewController () {

    float earthRadius, distanceAU, whScale;  // used to scale values
	CGPoint _moveDist[6];  // used to store rotation speeds
	SphereModel *_sphereModel, *_sun, *_moon, *_venus, *_mars, *_mercury;  // sphere shapes
    ImageTexture *_earthTexture, *_sunTexture, *_moonTexture, *_venusTexture, *_marsTexture, *_mercuryTexture;  // textures
}

@property (strong, nonatomic) EAGLContext *context;

- (void)setupGL;
- (void)tearDownGL;
- (void)setupOrthographicView: (CGSize)size;

@end

@implementation ViewController

- (void)viewDidLoad {
    
	[super viewDidLoad];
    
    earthRadius = 1.0;  // I use these values to scale in the drawing section below
    distanceAU = 12.0;
    whScale = 15;  // to be set and checked later. stands for width height scale. used in setupOrthographicView below
	
	self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];

	if (!self.context) {
		NSLog(@"Failed to create ES context");
	}
	
	GLKView *view = (GLKView *)self.view;
	view.context = self.context;
	view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    // the pinch gesture recognizer object below
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(respondsToPinch:)];
	
	[self setupGL];
}

- (void)dealloc {
    
	[self tearDownGL];
	
	if ([EAGLContext currentContext] == self.context) {
		[EAGLContext setCurrentContext:nil];
	}
}

- (void)didReceiveMemoryWarning {
    
	[super didReceiveMemoryWarning];

	if ([self isViewLoaded] && ([[self view] window] == nil)) {
		self.view = nil;
		
		[self tearDownGL];
		
		if ([EAGLContext currentContext] == self.context) {
			[EAGLContext setCurrentContext:nil];
		}
		self.context = nil;
	}
	// Dispose of any resources that can be recreated.
}

- (void)update {
    
	[self setupOrthographicView: self.view.bounds.size];
    // these values below are used in calculating the rotation speed of each planet
    _moveDist[0].x += self.timeSinceLastUpdate * 25;  // sun rotation speed
    _moveDist[0].y += self.timeSinceLastUpdate * 25;
    
    _moveDist[1].x += self.timeSinceLastUpdate * 25;  // earth rotation speed
    _moveDist[1].y += self.timeSinceLastUpdate * 25;
    
    _moveDist[2].x += (1/0.0748) - self.timeSinceLastUpdate;  // moon rotation speed
    _moveDist[2].y += (1/0.0748) - self.timeSinceLastUpdate;
    
    _moveDist[3].x += self.timeSinceLastUpdate * 25 * (1/0.615);  // venus rotation speed
    _moveDist[3].y += self.timeSinceLastUpdate * 25 * (1/0.615);
    
    _moveDist[4].x += self.timeSinceLastUpdate * 25 * (1/0.240);  // mercury rotation speed
    _moveDist[4].y += self.timeSinceLastUpdate * 25 * (1/0.240);
    
    _moveDist[5].x += self.timeSinceLastUpdate * 25 * (1/1.881);   // mars rotation speed
    _moveDist[5].y += self.timeSinceLastUpdate * 25 * (1/1.881);
}

- (void)setupGL {
    
	[EAGLContext setCurrentContext:self.context];
    
    /* Sphere models: */
	_sphereModel = [[SphereModel alloc] init:16];  // earth
    _sun = [[SphereModel alloc] init: 16];  // sun
    _moon = [[SphereModel alloc] init: 16];  // moon
    _venus = [[SphereModel alloc] init: 16];  // venus
    _mars = [[SphereModel alloc] init: 16];  // mars
    _mercury = [[SphereModel alloc] init: 16];  // mercury
    
    /* Textures: */
	_earthTexture = [[ImageTexture alloc] initFrom:@"earth.png"];
    _sunTexture = [[ImageTexture alloc] initFrom:@"Sun.png"];  // sun texture binding
    _moonTexture = [[ImageTexture alloc] initFrom:@"Moon.png"];  // moon
    _venusTexture = [[ImageTexture alloc] initFrom:@"Venus.png"];  // venus
    _marsTexture = [[ImageTexture alloc] initFrom:@"Mars.png"]; // mars
    _mercuryTexture = [[ImageTexture alloc] initFrom:@"Mercury.png"]; // mercury

	glEnable(GL_CULL_FACE);
	glCullFace(GL_BACK);
	glEnable(GL_DEPTH_TEST);
	glDepthFunc(GL_LEQUAL);
    
    /* Lighting code here below */
    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);
    const GLfloat light0ambient[] = {1, 1, 1, 1.0};  // white
    const GLfloat light0diffuse[] = {0.7, 0.7, 0.7, 1.0};
    const GLfloat light0specular[] = {0.7, 0.7, 0.7, 1.0};
    const GLfloat light0pos[] = {0, 0, 7, 1};  // 7 on the z axis

    glLightfv(GL_LIGHT0, GL_DIFFUSE, light0diffuse);
    glLightfv(GL_LIGHT0, GL_SPECULAR, light0specular);
    glLightfv(GL_LIGHT0, GL_POSITION, light0pos);
    glLightfv(GL_LIGHT0, GL_AMBIENT, light0ambient);
    
	_moveDist[0].x = 40, _moveDist[0].y = 0;
	_moveDist[1].x = 60, _moveDist[1].y = 30;

    glClearColor(0, 0, 0, 1);
	glClearDepthf(1);
}

- (void)tearDownGL {
    
	[EAGLContext setCurrentContext:self.context];
}

- (void)setupOrthographicView: (CGSize)size {
    
	// set viewport based on display size
	glViewport(0, 0, size.width, size.height);
	float min = MIN(size.width, size.height);
	float width = whScale * size.width / min;  // class variable set above and checked below in event handler
	float height = whScale * size.height / min;  // used in 'zooming' the camera in and out

	// set up orthographic projection
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrthof(-width, width, -height, height, -2, 2);
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    
	// clear the rendering buffer
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	// set up the transformation for models
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	glEnableClientState(GL_VERTEX_ARRAY);
    /* the drawing of each planet is done here */
    glPushMatrix(); {  // sun drawing
        
        glRotatef(_moveDist[0].y, 0, 0, 1);  // rotates an angle about the z axis
        glTranslatef(0, 0, 0);
        glRotatef(_moveDist[0].x, 0, 0, 1);
        glScalef(2, 2, 2);  // scaled by 2.0 (sun is not proportionately to scale with other planets)
        
        [_sunTexture bind];  // bind texture to shape
        [_sun drawOpenGLES1];  // draw shape with texture
    }
    glPopMatrix();
    
    glPushMatrix(); {  // earth drawing
        
        glRotatef(_moveDist[1].y, 0.0, 0.0, 1.0);
        glTranslatef(0, distanceAU, 0);
        glRotatef(_moveDist[1].x, 0.0, 0.0, 1.0);
        glScalef(1, 1, 1); /* 1.2, 1.2 1.2 */
        
        glPushMatrix(); {  // moon drawing
            
            glRotatef(_moveDist[2].y, 0, 0, 1);
            glTranslatef(0, 0.15 * distanceAU, 0);
            glRotatef(_moveDist[2].x, 0, 0, 1);
            glScalef(0.273, 0.273, 0.273);
            
            [_moonTexture bind];
            [_moon drawOpenGLES1];
        }
        glPopMatrix();
        
        [_earthTexture bind];
        [_sphereModel drawOpenGLES1];
    }
    glPopMatrix();

    glPushMatrix(); {  // mercury drawing
        
        glRotatef(_moveDist[4].y, 0, 0, 1);
        glTranslatef(0, 0.387 * distanceAU, 0);
        glRotatef(_moveDist[4].x, 0, 0, 1);
        glScalef(0.383, 0.383, 0.383);
        
        [_mercuryTexture bind];
        [_mercury drawOpenGLES1];
    }
    glPopMatrix();
    
    glPushMatrix(); {  // venus drawing
        
        glRotatef(_moveDist[3].y, 0, 0, 1);
        glTranslatef(0, 0.723 * distanceAU, 0);
        glRotatef(_moveDist[3].x, 0, 0, 1);
        glScalef(0.950, 0.950, 0.950);
        
        [_venusTexture bind];
        [_venus drawOpenGLES1];
    }
    glPopMatrix();
    
    glPushMatrix(); {  // mars drawing
        
        glRotatef(_moveDist[5].y, 0, 0, 1);
        glTranslatef(0, 1.524 * distanceAU, 0);
        glRotatef(_moveDist[5].x, 0, 0, 1);
        glScalef(0.532, 0.532, 0.532);
        
        [_marsTexture bind];
        [_mars drawOpenGLES1];
    }
    glPopMatrix();
}

- (IBAction)respondsToPinch:(UIPinchGestureRecognizer*) sender {  // screen pinch event handler
    
    if (whScale > 15.0) {
        
        NSLog(@"> zooming back out");
        glRotatef(_moveDist[1].y, 0, 0, 1);
        glTranslatef(distanceAU, 0, 0);
        glRotatef(_moveDist[1].x, 0, 0, 1);
        whScale = 15.0;
    }
    // else, do nothing
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {  // screen touch event handler

	// get touch location & device display size
	CGPoint pos = [[touches anyObject] locationInView:self.view];
    float x = self.view.bounds.size.width/2.0 + (12.0 * cos(M_PI * _moveDist[1].x / 180.0));
    float y = self.view.bounds.size.height/2.0 + (12.0 * sin(M_PI * _moveDist[1].y / 180.0));
    
    if ( ((12 * pos.x >= x - 12.0) && (12 * pos.x <= x + 12.0)) && ((12 * pos.y >= y - 12.0) && (12 * pos.y <= y + 12.0)) ) {
        
        glRotatef(-_moveDist[1].y, 0, 0, 1);
        glTranslatef(-distanceAU, 0, 0);
        glRotatef(-_moveDist[1].x, 0, 0, 1);
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

}

@end
