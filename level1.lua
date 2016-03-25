-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "physics" library
local physics = require "physics"
physics.start(); physics.pause()

--physics.setDrawMode('hybrid')

physics.setGravity(0,100)

--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW, halfH = display.contentWidth, display.contentHeight, display.contentWidth*0.5, display.contentHeight*0.5

local origemx = display.contentWidth
local origemy = display.contentHeight

local meiox = display.contentCenterX
local  meioy = display.contentCenterY

local scroll = 4

local background = display.newImageRect("planets.jpg",screenW,screenH)
background.x = meiox
background.y = meioy

local background2 = display.newImageRect("planets.jpg",screenW,screenH)
background2.x = background.x + screenW
background2.y = meioy

local background3 = display.newImageRect("planets.jpg",screenW,screenH)
background3.x = background2.x + screenW
background3.y = meioy

local pontuacaoTxt = display.newText( "Peso atual: "..pontuacao, 60, 15, "Helvetica", 20)
pontuacaoTxt:setTextColor ( 255, 0, 0 )

quadradoMal = display.newImage("quadradoAzul.png")
quadradoMal.alpha = 0
quadradoMal.xScale = 0.25
quadradoMal.yScale = 0.25
--quadradoMal:scale(.05,.05)
quadradoMal.name = "quadradoMal"
quadradoMal.x = meiox
physics.addBody(quadradoMal, { radius=20})

listaInimigos = {
[0] = quadradoMal
}

local inimigo
local tm

function scene:create( event )

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view

	--local background = display.newImage("bg.png")
	--background.anchorX = 0
	--background.anchorY = 0

	quadrado = display.newImage("quadradoAzul.png", (halfW * 0.50), (screenH * 0.60))
	quadrado.xScale = 0.5
	quadrado.yScale = 0.5
	quadrado.myName = "quadradoAzul"

	scene.view:insert(background)
	--scene.view:insert(background2)
	--scene.view:insert(background3)
	scene.view:insert(pontuacaoTxt)

	inimigos = display.newGroup()
	scene.view:insert(inimigos)
	inimigos:insert( quadradoMal )

	physics.addBody(quadrado, "dynamic")
	
	sceneGroup:insert(quadrado)

	--[[
	-- create a grey rectangle as the backdrop
	local background = display.newRect( 0, 0, screenW, screenH )
	background.anchorX = 0
	background.anchorY = 0
	background:setFillColor( .5 )
	
	-- make a crate (off-screen), position it, and rotate slightly
	local crate = display.newImageRect( "crate.png", 90, 90 )
	crate.x, crate.y = 160, -100
	crate.rotation = 15
	
	-- add physics to the crate
	physics.addBody( crate, { density=1.0, friction=0.3, bounce=0.3 } )
	
	-- create a grass object and add physics (with custom shape)
	local grass = display.newImageRect( "grass.png", screenW, 82 )
	grass.anchorX = 0
	grass.anchorY = 1
	grass.x, grass.y = 0, display.contentHeight
	
	-- define a shape that's slightly shorter than image bounds (set draw mode to "hybrid" or "debug" to see)
	local grassShape = { -halfW,-34, halfW,-34, halfW,34, -halfW,34 }
	physics.addBody( grass, "static", { friction=0.3, shape=grassShape } )
	
	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( grass)
	sceneGroup:insert( crate )
	]]
end

function aplicarForca()

	if quadrado.y > screenH * 0.5 then
		quadrado:applyForce(0, -600, quadrado.x, quadrado.y)
	else
		quadrado:applyForce(0, 600, quadrado.x, quadrado.y)
	end	
end

function touch(event)

	if event.phase == "began" then
		quadrado.enterFrame = aplicarForca
		Runtime:addEventListener("enterFrame", quadrado)
	end

	if event.phase == "ended" then
		Runtime:removeEventListener("enterFrame", quadrado)
	end
end

function atualizar()
	if quadrado.y > screenH * 0.5 then
		quadrado.gravityScale = 1
	else
		quadrado.gravityScale = -1
	end	
end

function backgroundLoop(event)
		background.x = background.x - scroll
		background2.x = background2.x - scroll
		background3.x = background3.x - scroll

	if (background.x + background.contentWidth) < 0 then
		background:translate(halfW * 3,0)
	end
	if (background2.x + background2.contentWidth) < 0 then
		background2:translate( halfW * 3,0 )
	end
	if (background3.x + background3.contentWidth) < 0 then
		background3:translate( halfW * 3,0 )
	end
end

function mostrarQuadrados(event)
local na = criarMaisQuadrados()
indice = math.random(0,7)
	inimigo = listaInimigos[0]
	inimigo.alpha = 1
	inimigo.x = _W + 100
	inimigo.y = math.random(0, screenH)
	transition.to( inimigo, {time = 3500, rotation = -180, x = -100, y = inimigo.y, onComplete = removerQuadrado})
end

function criarMaisQuadrados()
if (pontuacao <= 140 and pontuacao > 120) then
return 2
end
if (pontuacao <= 120 and pontuacao > 90) then
return 3
end
if (pontuacao <= 90) then
return 4
end
if(pontuacao > 140) then
return 1
end
end

function colisao(event)
if ( event.phase == "began" ) then
if(event.object1.name == "quadradoAzul" and event.object2.name == "quadradoMal" and event.object1.alpha == 1) then 
event.object1.alpha = 0
pontuacao = pontuacao - 1
atualizarPontuacao()
end
if(event.object1.name == "quadradoMal" and event.object2.name == "quadradoAzul" and event.object2.alpha == 1) then
event.object2.alpha = 0
pontuacao = pontuacao - 1
atualizarPontuacao()
end
end
end

function atualizarPontuacao()
pontuacaoTxt.text = string.format( "Peso atual: %d", pontuacao)
end

function removerQuadrado()
inimigo.rotation = -45
inimigo.alpha = 0
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
		physics.start()

		-- Runtime:addEventListener("enterFrame", backgroundLoop)
		Runtime:addEventListener("touch", touch)
		Runtime:addEventListener("enterFrame", atualizar)
		tm = timer.performWithDelay( 4000,mostrarQuadrados ,0)
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
		physics.stop()
	elseif phase == "did" then
		-- Called when the scene is now off screen

		Runtime:removeEventListener("touch", touch)
		Runtime:removeEventListener("enterFrame", atualizar)
		-- Runtime:removeEventListener("enterFrame", backgroundLoop)
	end	
	
end

function scene:destroy( event )

	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	local sceneGroup = self.view
	
	package.loaded[physics] = nil
	physics = nil
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene