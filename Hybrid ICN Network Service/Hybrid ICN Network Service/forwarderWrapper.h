//
//  forwarderWrapper.h
//  Hybrid ICN Network Service
//
//  Created by manangel on 4/1/20.
//

#ifndef forwarderWrapper_h
#define forwarderWrapper_h


#include <stdio.h>
int isRunning();
void stopHicnFwd();
void startHicnFwd(const char *path, size_t pathSize);

#endif /* forwarderWrapper_h */
