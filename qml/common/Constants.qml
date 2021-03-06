pragma Singleton
import VPlay 2.0
import QtQuick 2.0

Item {
  id: constants

  // create on your own license key on http://www.v-play.net/license
  readonly property string licenseKey: "<your-license-key>"

  // VPlayGameNetwork - set your own gameId and secret after you created your own game here: http://gamenetwork.v-play.net/
  readonly property int gameId: 230
  readonly property string gameSecret: "onu"

  // VPlayMultiplayer - set your own appKey and pushKey after you created your own game here: http://gamenetwork.v-play.net/
  readonly property string appKey: "c2e647ce-5a83-4153-ae62-5c7d349ba87e"
  readonly property string pushKey: "JYnG49n8sI5wXsTcdTx8XDZXSefAEaivUMcdMLUl@cI7t1EIp6AYi7qFhY9CdACyYlVpxqlHPZeeqZF4X"

  // Facebook - add your Facebook app-id here (as described in the plugin documentation)
  readonly property string fbAppId: "<your-app-id>"

  // Google Analytics - add your property id from Google Analytics here (as described in the plugin documentation)
  readonly property string gaPropertyId: "<your-property-id>"

  // Flurry - from flurry dashboard
  readonly property string flurryApiKey: "<your-flurry-apikey>"

  // AdMob - add your adMob banner and insterstial unit ids here (as described in the plugin documentation)
  readonly property string adMobBannerUnitId: "<your-ad-mob-banner-id>"
  readonly property string adMobInterstitialUnitId: "<your-ad-mob-interstitial-id>"
  readonly property var adMobTestDeviceIds: [
    "<your-test-device-id>"
  ]

  // for sending feedback via a php script, use a password
  readonly property string feedbackSecret: "<secret-for-feedback-dialog>"
  readonly property string ratingUrl: "<your-rating-url>" // url to open on device for rating the app

  // Soomla In-App Purchases - add your configuration here
  readonly property string soomlaSecret: "<your-soomla-secret>"
  readonly property string soomlaAndroidKey: "<your-android-key>"
  readonly property string currencyId: "<your-currency-id>"
  readonly property string currency100PackId: "<your-pack1-storeproduct-id>"
  readonly property string currency500PackId: "<your-pack2-storeproduct-id>"
  readonly property string currency1000PackId: "<your-pack3-storeproduct-id>"
  readonly property string currency5000PackId: "<your-pack4-storeproduct-id>"

  // game configuration
  readonly property bool enableStoreAndAds: true // whether in-game store and ads are enabled, if set to false the game is 100% free to play
  readonly property bool simulateStore: true     // if the store should be simulated locally or actually use the soomla plugin to purchase goods
  readonly property bool lockScreenForInterstitial: false // locks screen to prevent user-action while interstitial is opening up
}
