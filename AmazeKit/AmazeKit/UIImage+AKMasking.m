//
//  UIImage+AKMasking.m
//  AmazeKit
//
//  Created by Jeff Kelley on 8/29/12.
//  Copyright (c) 2013 Detroit Labs. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//


#import "UIImage+AKMasking.h"


@implementation UIImage (AKMasking)


// Credit: http://stackoverflow.com/questions/8126276/how-to-convert-uiimage-cgimagerefs-alpha-channel-to-mask
- (UIImage *)AK_reverseMaskImage
{
	// Original RGBA image
	CGImageRef originalMaskImage = [self CGImage];
	float width = CGImageGetWidth(originalMaskImage);
	float height = CGImageGetHeight(originalMaskImage);
	
	// Make a bitmap context that's only 1 alpha channel
	uint8_t *alphaData = calloc(width * height, sizeof(uint8_t));
	CGContextRef alphaOnlyContext = CGBitmapContextCreate(alphaData,
														  width,
														  height,
														  8,
														  width,
														  NULL,
														  kCGImageAlphaOnly);
	
	// Draw the RGBA image into the alpha-only context.
	CGContextDrawImage(alphaOnlyContext, CGRectMake(0, 0, width, height), originalMaskImage);
	
	CGImageRef alphaMaskImage = CGBitmapContextCreateImage(alphaOnlyContext);
	CGContextRelease(alphaOnlyContext);
	free(alphaData);
	
	// Make a mask
	CGImageRef finalMaskImage = CGImageMaskCreate(CGImageGetWidth(alphaMaskImage),
												  CGImageGetHeight(alphaMaskImage),
												  CGImageGetBitsPerComponent(alphaMaskImage),
												  CGImageGetBitsPerPixel(alphaMaskImage),
												  CGImageGetBytesPerRow(alphaMaskImage),
												  CGImageGetDataProvider(alphaMaskImage), NULL, false);
	CGImageRelease(alphaMaskImage);
	
	UIImage *reverseMask = [[UIImage alloc] initWithCGImage:finalMaskImage
													  scale:[self scale]
												orientation:[self imageOrientation]];
	
	CGImageRelease(finalMaskImage);
	
	return reverseMask;
}

- (UIImage *)AK_reverseMaskImageNoFeather
{
	// Original RGBA image
	CGImageRef originalMaskImage = [self CGImage];
	float width = CGImageGetWidth(originalMaskImage);
	float height = CGImageGetHeight(originalMaskImage);
	
	// Make a bitmap context that's only 1 alpha channel
	uint8_t * alphaData = calloc(width * height, sizeof(uint8_t));
	CGContextRef alphaOnlyContext = CGBitmapContextCreate(alphaData,
														  width,
														  height,
														  8,
														  width,
														  NULL,
														  kCGImageAlphaOnly);
	
	// Draw the RGBA image into the alpha-only context.
	CGContextDrawImage(alphaOnlyContext, CGRectMake(0, 0, width, height), originalMaskImage);
	
	// Make the values either 0 or UINT8_MAX.
	for (int y = 0; y < height; y++) {
		for (int x = 0; x < width; x++) {
			uint8_t val = alphaData[(y * (int)width) + x];
			
			val = val > 0 ? UINT8_MAX : 0;
			
			alphaData[(y * (int)width) + x] = val;
		}
	}
	
	CGImageRef alphaMaskImage = CGBitmapContextCreateImage(alphaOnlyContext);
	CGContextRelease(alphaOnlyContext);
	free(alphaData);
	
	// Make a mask
	CGImageRef finalMaskImage = CGImageMaskCreate(CGImageGetWidth(alphaMaskImage),
												  CGImageGetHeight(alphaMaskImage),
												  CGImageGetBitsPerComponent(alphaMaskImage),
												  CGImageGetBitsPerPixel(alphaMaskImage),
												  CGImageGetBytesPerRow(alphaMaskImage),
												  CGImageGetDataProvider(alphaMaskImage), NULL, false);
	CGImageRelease(alphaMaskImage);
	
	UIImage *reverseMask = [[UIImage alloc] initWithCGImage:finalMaskImage
													  scale:[self scale]
												orientation:[self imageOrientation]];
	
	CGImageRelease(finalMaskImage);
	
	return reverseMask;
}

@end
