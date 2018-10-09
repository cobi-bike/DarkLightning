/**
 *	The MIT License (MIT)
 *
 *	Copyright (c) 2015 Jens Meder
 *
 *	Permission is hereby granted, free of charge, to any person obtaining a copy of
 *	this software and associated documentation files (the "Software"), to deal in
 *	the Software without restriction, including without limitation the rights to
 *	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 *	the Software, and to permit persons to whom the Software is furnished to do so,
 *	subject to the following conditions:
 *
 *	The above copyright notice and this permission notice shall be included in all
 *	copies or substantial portions of the Software.
 *
 *	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 *	FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 *	COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 *	IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 *	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "JMNativeSocket.h"

@implementation JMNativeSocket

@synthesize inputStream = _inputStream;
@synthesize outputStream = _outputStream;
@synthesize state = _state;

-(instancetype)initWithNativeSocket:(CFSocketNativeHandle)nativeSocket
{
	if (nativeSocket < 0)
	{
		return nil;
	}
	
	self = [super init];
	
	if (self)
	{
		_nativeSocket = nativeSocket;
	}
	
	return self;
}

-(BOOL)connect
{
	if (self.state != JMSocketStateDisconnected)
	{
		return NO;
	}
	
	self.state = JMSocketStateConnecting;
	
	CFReadStreamRef readStream;
	CFWriteStreamRef writeStream;
	
	CFStreamCreatePairWithSocket(kCFAllocatorDefault, _nativeSocket, &readStream, &writeStream);
	
	CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
	CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
	
	_inputStream = (__bridge NSInputStream *)(readStream);
	_outputStream = (__bridge NSOutputStream *)(writeStream);

    CFRelease(readStream);
    CFRelease(writeStream);
	
	self.state = JMSocketStateConnected;
	
	return YES;
}

-(BOOL)disconnect
{
	if (self.state == JMSocketStateDisconnected)
	{
		return YES;
	}
	
	self.state = JMSocketStateDisconnected;
	
	[_inputStream close];
	[_outputStream close];
	
	_inputStream = nil;
	_outputStream = nil;
	
	return YES;
}

#pragma mark - Properties

-(void) setState:(JMSocketState)state
{
	if (state == _state)
	{
		return;
	}
	
	_state = state;
}


@end
