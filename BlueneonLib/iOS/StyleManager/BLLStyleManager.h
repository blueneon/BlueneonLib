//
//  BLLStyleManager.h
//  TheNobleSage
//
//  Created by Alex Carter on 10-07-27.
//
//  Copyright 2011 Alex Carter. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of
//  conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list
//  of conditions and the following disclaimer in the documentation and/or other materials
//  provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY <COPYRIGHT HOLDER> ``AS IS'' AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those of the
//  authors and should not be interpreted as representing official policies, either expressed
//  or implied, of Alex Carter.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>



typedef enum BLLStyleFontID {
	BLLStyleFontID_00,	
	BLLStyleFontID_01,	
	BLLStyleFontID_02,	
	BLLStyleFontID_03,	
	BLLStyleFontID_04,
	BLLStyleFontID_05,	
	BLLStyleFontID_06,	
	BLLStyleFontID_07,	
	BLLStyleFontID_08,	
	BLLStyleFontID_09,
	BLLStyleFontID_10,	
	BLLStyleFontID_11,	
	BLLStyleFontID_12,	
	BLLStyleFontID_13,	
	BLLStyleFontID_14,
	BLLStyleFontID_15,	
	BLLStyleFontID_16,	
	BLLStyleFontID_17,	
	BLLStyleFontID_18,	
	BLLStyleFontID_19
} BLLStyleFontID;

typedef enum BLLStyleColorID {
	BLLStyleColorID_00,	
	BLLStyleColorID_01,	
	BLLStyleColorID_02,	
	BLLStyleColorID_03,	
	BLLStyleColorID_04,
	BLLStyleColorID_05,	
	BLLStyleColorID_06,	
	BLLStyleColorID_07,	
	BLLStyleColorID_08,	
	BLLStyleColorID_09,
	BLLStyleColorID_10,	
	BLLStyleColorID_11,	
	BLLStyleColorID_12,	
	BLLStyleColorID_13,	
	BLLStyleColorID_14,
	BLLStyleColorID_15,	
	BLLStyleColorID_16,	
	BLLStyleColorID_17,	
	BLLStyleColorID_18,	
	BLLStyleColorID_19
} BLLStyleColorID;


@interface BLLStyleManager : NSObject {
	NSDictionary* _styleInfo;	
}

+(BLLStyleManager*) defaultStyleManager;
+(UIColor*) colorWithStyleID:(BLLStyleColorID) styleID;
+(UIFont*) fontWithStyleID:(BLLStyleFontID) styleID;
+(CTFontRef) createCTFontWithStyleID:(BLLStyleFontID) styleID;
	
@end
