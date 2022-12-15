//
//  AdMobIdentifier.swift
//  SafelyHunt
//
//  Created by Yoan on 14/12/2022.
//

import Foundation
struct AdMobIdentifier {

    func videoAwardDoubleGainsId() -> String {
#if Debug
        return "ca-app-pub-3940256099942544/1712485313"
#else
        return "ca-app-pub-3063172456794459/1289374865"
#endif
    }

    func videoAwardLevelId() -> String {
#if Debug
        return "ca-app-pub-3940256099942544/1712485313"
#else
        return "ca-app-pub-3063172456794459/3470661557"
#endif
    }

    func bannerIdMainStarter() -> String {
#if Debug
        return "ca-app-pub-3940256099942544/2934735716"
#else
        return "ca-app-pub-3063172456794459/9677510087"
#endif
    }
}
