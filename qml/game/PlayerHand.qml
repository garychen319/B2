import QtQuick 2.0
import VPlay 2.0

// the cards in the hand of the player
Item {
  id: playerHand
  width: 400
  height: 134

  property double zoom: 1.0
  property int originalWidth: 400
  property int originalHeight: 134

  // amount of cards in hand in the beginning of the game
  property int start: 13
  // array with all cards in hand
  property var hand: []
  // the owner of the cards
  property var player: MultiplayerUser{}
  // whether the player pressed the ONUButton or not
  property bool onu: false
  // the score at the end of the game
  property int score: 0
  // value used to spread the cards in hand
  property double offset: width/10


  // sound effect plays when drawing a card
  SoundEffectVPlay {
    volume: 0.5
    id: drawSound
    source: "../../assets/snd/draw.wav"
  }

  // sound effect plays when depositing a card
  SoundEffectVPlay {
    volume: 0.5
    id: depositSound
    source: "../../assets/snd/deposit.wav"
  }

  // sound effect plays when winning the game
  SoundEffectVPlay {
    volume: 0.5
    id: winSound
    source: "../../assets/snd/win.wav"
  }

  // playerHand background image
  // the image changes for the active player
  Image {
    id: playerHandImage
    source: multiplayer.activePlayer === player && !gameLogic.acted? "../../assets/img/PlayerHand2.png" : "../../assets/img/PlayerHand1.png"
    width: parent.width / 400 * 560
    height: parent.height / 134 * 260
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: parent.height * (-0.5)
    z: 0
    smooth: true

    onSourceChanged: {
      z = 0
      neatHand()
    }
  }

  // playerHand blocked image is visible when the player gets skipped
  Image {
    anchors.bottom: parent.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    source: "../../assets/img/Blocked.png"
    width: 170
    height: width
    z: 100
    visible: depot.skipped && multiplayer.activePlayer == player
    smooth: true
  }

  // playerHand bubble image is visible when the player pressed the ONUButton
  Image {
    anchors.top: parent.top
    anchors.right: parent.right
    source: "../../assets/img/Bubble.png"
    rotation: parent.rotation * (-1)
    width: 60
    height: width
    z: 100
    visible: onu
    smooth: true
  }

  // start the hand by picking up a specified amount of cards
  function startHand(){
    pickUpCards(start)
  }

  // reset the hand by removing all cards
  function reset(){
    while(hand.length) {
      hand.pop()
    }
    onu = true
    scaleHand(1.0)
  }

  // organize the hand and spread the cards
  function neatHand(){
    // sort all cards by their natural order
    hand.sort(function(a, b) {
      return a.order - b.order
    })

    // recalculate the offset between cards if there are too many in the hand
    // make sure they stay within the playerHand
    offset = originalWidth * zoom / 10
    if (hand.length > 7){
      offset = playerHand.originalWidth * zoom / hand.length / 1.5
    }

    // calculate the card position and rotation in the hand and change the z order
    for (var i = 0; i < hand.length; i ++){
      var card = hand[i]
      // angle span for spread cards in hand
      var handAngle = 40
      // card angle depending on the array position
      var cardAngle = handAngle / hand.length * (i + 0.5) - handAngle / 2
      //offset of all cards + one card width
      var handWidth = offset * (hand.length - 1) + card.originalWidth * zoom
      // x value depending on the array position
      var cardX = (playerHand.originalWidth * zoom - handWidth) / 2 + (i * offset)

      card.rotation = cardAngle
      card.y = Math.abs(cardAngle) * 1.5
      card.x = cardX
      card.z = i + 50 + playerHandImage.z
    }
  }

  // pick up specified amount of cards

  function pickUpCards(amount){
    onuButton.button.enabled = true
    var pickUp = deck.handOutCards(amount)
    // add the stack cards to the playerHand array
    for (var i = 0; i < pickUp.length; i ++){
      hand.push(pickUp[i])
      changeParent(pickUp[i])
      if (multiplayer.localPlayer == player){
        pickUp[i].hidden = false
      }
      drawSound.play()
    }
    // reorganize the hand
    neatHand()
  }


  // change the current hand card array
  function syncHand(cardIDs) {
    hand = []
    for (var i = 0; i < cardIDs.length; i++){
      var tmpCard = entityManager.getEntityById(cardIDs[i])
      hand.push(tmpCard)
      changeParent(tmpCard)
      deck.cardsInStack --
      if (multiplayer.localPlayer == player){
        tmpCard.hidden = false
      }
      drawSound.play()
    }
    // reorganize the hand
    neatHand()
  }

  // change the parent of the card to playerHand
  function changeParent(card){
    card.newParent = playerHand
    card.state = "player"
  }

  // check if a card with a specific id is on this hand
  function inHand(cardId){
    for (var i = 0; i < hand.length; i ++){
      if(hand[i].entityId === cardId){
        return true
      }
    }
    return false
  }

  // remove card with a specific id from hand
  function removeFromHand(cardId){
    for (var i = 0; i < hand.length; i ++){
      if(hand[i].entityId === cardId){
        hand[i].width = hand[i].originalWidth
        hand[i].height = hand[i].originalHeight
        hand.splice(i, 1)
        depositSound.play()
        neatHand()
        return
      }
    }
  }

  // highlight all valid cards by setting the glowImage visible
  function markValid(){
    if (!depot.skipped && !gameLogic.gameOver && !colorPicker.chosingColor){
      for (var i = 0; i < hand.length; i ++){
        if (depot.validCard(hand[i].entityId)){
          hand[i].glowImage.visible = true
          hand[i].updateCardImage()
        }else{
          hand[i].glowImage.visible = false
          hand[i].saturation = -0.5
          hand[i].lightness = 0.5
        }
      }
      // mark the stack if there are no valid cards in hand
      var validId = randomValidId()
      if(validId == null){
        deck.markStack()
      }
    }
  }

  // unmark all cards in hand
  function unmark(){
    for (var i = 0; i < hand.length; i ++){
      hand[i].glowImage.visible = false
      hand[i].updateCardImage()
    }
  }

  // scale the whole playerHand of the active localPlayer with a zoom factor
  function scaleHand(scale){
    zoom = scale
    playerHand.height = playerHand.originalHeight * zoom
    playerHand.width = playerHand.originalWidth * zoom
    for (var i = 0; i < hand.length; i ++){
      hand[i].width = hand[i].originalWidth * zoom
      hand[i].height = hand[i].originalHeight * zoom
    }
    neatHand()
  }

  // get a random valid card id from the playerHand
  function randomValidId(){
    var valids = getValidCards()
    if (valids.length > 0){
      // return a random valid card from the array
      var randomIndex = Math.floor(Math.random() * (valids.length))
      return valids[randomIndex].entityId
    }else{
      return null
    }
  }

  // get an array with all valid cards
  function getValidCards(){
    var valids = []
    // put all valid card options in the array
    for (var i = 0; i < hand.length; i ++){
      if (depot.validCard(hand[i].entityId)){
        valids.push(entityManager.getEntityById(hand[i].entityId))
      }
    }
    return valids
  }

  // if the player deposited their second to last card without pressing onu
  // they missed their chance to activate the ONUButton
  function missedOnu(){
    if (hand.length === 0 && !onu){
      if (multiplayer.myTurn) onuButton.button.enabled = true
      return true
    } else {
      return false
    }
  }

  // check if the player can activate the onu button
  function closeToWin(){
    // if the player has 2 or less cards in his hand

      // automatically activate onu for the player if he's disconnected or when the ONUButton is removed from the game (onuButton.visible = false)
      // do not auto-activate it when the player is skipped, onu is already active or the game is already over
      var userDisconnected = (!multiplayer.activePlayer || !multiplayer.activePlayer.connected)
      if ((!onuButton.visible || userDisconnected) && !depot.skipped && !onu && !gameLogic.gameOver){
        var userId = multiplayer.activePlayer ? multiplayer.activePlayer.userId : 0
        onuButton.onu(userId)

      onuButton.button.enabled = true
      // enable the button if the active player is connected
      var valids = getValidCards()
      if (multiplayer.myTurn && !depot.skipped && !gameLogic.gameOver && !onu && valids.length > 0){
        onuButton.button.enabled = true
      } else if (multiplayer.myTurn){
        onuButton.button.enabled = true
      }
      return true
    }
  }

  // check if the player has won with zero cards left
  function checkWin(){
    if (hand.length == 0){
      winSound.play()
      return true
    }else{
      return false
    }
  }

  // calculate all card points in hand
  function points(){
    var points = 0
    for (var i = 0; i < hand.length; i++) {
      points += hand[i].points
    }
    return points
  }

  // animate the playerHand width and height
  Behavior on width {
    NumberAnimation { easing.type: Easing.InOutQuad; duration: 400 }
  }

  Behavior on height {
    NumberAnimation { easing.type: Easing.InOutQuad; duration: 400 }
  }
}
