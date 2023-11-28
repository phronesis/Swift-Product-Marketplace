import Amplify
import Foundation
enum MarketplaceError: Error {
    case amplify(AmplifyError)
}
