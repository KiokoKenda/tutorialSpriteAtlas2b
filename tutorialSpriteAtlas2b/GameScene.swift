//
//  GameScene.swift
//  tutorialSpriteAtlas2b
//
//  Created by Gianluca on 09/04/15.
//  Copyright (c) 2015 KiokoKenda. All rights reserved.
//

import SpriteKit

// decidiamo le variabili globali per interagire col gioco
// il personaggio
var player : SKSpriteNode!
// e un array contenente ogni singola immagine che andra' a formare l'animazione,
// in questo caso, la camminata del personaggio
var playerWalkingFrames : [SKTexture]!

// per comodita' di lettura definisco 2 costanti che useremo per girare il personaggio
let SINISTRA = CGFloat(-1)
let DESTRA = CGFloat(1)

class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        // iniziamo con il modo classico di caricare una immagine di sfondo come ripasso
        let backGround = SKSpriteNode(imageNamed: "nar-konoha-street1.jpg")
        // posizioniamo lo sfondo al centro della scena
        backGround.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        // la ridimensioniamo per adattarla alla dimensione dello schermo
        backGround.size.width = self.frame.width
        // aggiungiamo alla scena lo sfondo
        self.addChild(backGround)
        ///////////////////////////////////////////////////////////////////////////////////////
        
        // indichiamo il nome del nostro Atlas da cui recuperare le immagini
        let playerAnimatedAtlas = SKTextureAtlas(named: "naruto")
        // ed inizializziamo l'array che contiene le immagini della sequenza animata
        playerWalkingFrames = [SKTexture]()
        
        // otteniamo il numero di immagini (ricordiamoci che count restituisce il conteggio +1)
        let numImages = playerAnimatedAtlas.textureNames.count-1
        // ora possiamo riempire l'array con le immagini necessarie
        for i in 1...numImages {
            // nel file plist possiamo osservare che le singole immagini sono numerate "nome0"+i
            // quindi le indichiamo proprio usando questi parametri
            let playerTextureName = "naruto0\(i)"
            println("naruto0\(i) loaded")
            playerWalkingFrames.append(playerAnimatedAtlas.textureNamed(playerTextureName))
        }

        // qui decidiamo quale fra tutte sara' l'immagine per il personaggio fermo
        let firstFrame = playerWalkingFrames[1]
        player = SKSpriteNode(texture: firstFrame)
        player.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        // le immagini sono piccoline, quindi raddoppio le dimensioni del personaggio
        player.size.width *= 2
        player.size.height *= 2
        // infine lo aggiungo alla scena
        addChild(player)
        
        // iniziamo a far muovere il personaggio per vederlo in azione
        walkingPlayer()

    }
    
    func walkingPlayer() {
        // questa sara' la funzione che creera' ed eseguira' l'azione della camminata
        
        // come parametri della action da eseguire passeremo:
        // repeatActionForever per indicare che il personaggio deve continuare ad eseguire l'azione
        player.runAction(SKAction.repeatActionForever(
            // animateWithTextures, ovvero di usare le textures contenute nel nostro array
            SKAction.animateWithTextures(playerWalkingFrames,
                // la velocita' di esecuzione dell'azione
                timePerFrame: 0.2,
                // deve mantenere le dimensioni della sprite come le abbiamo definite
                resize: false,
                // restore true indica che la sprite, una volta terminata la camminata, deve riprendere la posizione che abbiamo fissato come iniziale (la abbiamo indicata in firstFrame ed usata per creare il personaggio), se false il personaggio si arrestera' con l'ultima immagine usata durante la camminata
                restore: true)),
            // ed assegnamo all'azione un nome
            withKey:"standingInPlacePlayer")
    }
    func playerMoveEnded() {
        // per fermare il personaggio basta semplicemente eliminare tutte le actions
        player.removeAllActions()
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        //(touches: NSSet, withEvent event: UIEvent)
        /* Called when a touch begins */

    }
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        // rileviamo la posizione del tocco su schermo
        let touch = touches.first as? UITouch
        let location = touch!.locationInNode(self)
        
        // settiamo la velocita' in modo che il personaggio impieghi 3 secondi ad attraversare tutto lo schermo
        let playerVelocity = self.frame.size.width / 3.0
        
        // un po' di matematica ><
        // la stessa cosa che fa peppe nel tutorial SpriteKit con il ninja
        // stabiliamo punto di arrivo e distanza (ipotenusa di un triangolo)
        let moveDifference = CGPointMake(location.x - player.position.x, location.y - player.position.y)
        let distanceToMove = sqrt(moveDifference.x * moveDifference.x + moveDifference.y * moveDifference.y)
        ////////////////////////////////////////////////////////////////////////////////////
        
        // e finalmente possiamo usare questa distanza per calcolare la durata della animazione in base alla velocita' che abbiamo dato al personaggio
        let moveDuration = distanceToMove / playerVelocity
        
        // per 'specchiare' la sprite nel caso di cambio direzione impostiamo una var direzione
        // che useremo come moltiplicatore
        var direzione: CGFloat
        if (moveDifference.x < 0) {
            // se moveDifference.x e' negativo significa che abbiamo toccato a sinistra del personaggio, quindi moltiplicheremo xScale * -1 per girarlo a sinistra
            direzione = SINISTRA
        } else {
            // altrimenti xScale * 1 per girarlo a destra
            direzione = DESTRA
        }
        player.xScale = fabs(player.xScale) * direzione
        ////////////////////////////////////////////////////////////////////////////////////
        
        // ora che abbiamo verificato la direzione, processiamo i vari casi del movimento
        // != nil significa che e' in esecuzione
        // quindi controllo se e' in esecuzione la camminata
        if (player.actionForKey("playerMoving") != nil) {
            println("il personaggio qui cambia direzione")
            // removeActionForKey ferma l'azione e la cancella
            player.removeActionForKey("playerMoving")
        }
        
        // al contrario, se nn si stava muovendo...
        if (player.actionForKey("standingInPlacePlayer") == nil) {
            // e' fermo, fallo iniziare a camminare
            println("qui inizia a camminare")
            walkingPlayer()
        }
        
        // creiamo l'azione dove indichiamo dove andare e quanto impiegare
        let moveAction = (SKAction.moveTo(location, duration:(Double(moveDuration))))
        
        // creiamo un azione per quando ha completato il viaggio
        let doneAction = (SKAction.runBlock( {
            println("il personaggio e' arrivato al punto")
            self.playerMoveEnded()
        }))
        
        // finalmente uniamo le 2 azioni precedenti per creare una azione complessa formata da un percorso e successiva fermata
        let moveActionWithDone = (SKAction.sequence([moveAction, doneAction]))
        player.runAction(moveActionWithDone, withKey:"playerMoving")
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
