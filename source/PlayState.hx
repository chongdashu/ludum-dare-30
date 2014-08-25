package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.group.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxMath;

import flixel.util.FlxPoint;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import openfl.Assets;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
    /**
     * Some static constants for the size of the tilemap tiles
     */
    private static inline var TILE_WIDTH  : Int = 16;
    private static inline var TILE_HEIGHT : Int = 16;

    public var level : FlxTilemap;
    
    public var buttons : Array<FlxButton>;

    public var guards : FlxTypedGroup<FlxSprite>;
    public var crates : FlxTypedGroup<FlxSprite>;
    public var stones : FlxTypedGroup<FlxSprite>;
    public var keys : FlxTypedGroup<FlxSprite>;
    public var exits : FlxTypedGroup<FlxSprite>;

    public var world1Guard : FlxSprite;
    public var world3Exit : FlxSprite;

    // World 1
    public var combinedGuard : FlxSprite;
    public var combinedCrate1 : FlxSprite;
    public var combinedCrate2 : FlxSprite;
    public var isCombinedGuardOnCrate : Bool;

    // World 2
    public var combinedWorld2Key : FlxSprite;
    public var combinedWorld2Stone1 : FlxSprite;
    public var combinedWorld2Stone2 : FlxSprite;
    public var combinedWorld2Stone3 : FlxSprite;
    public var isKeyCollected : Bool;

    // World 3
    public var combinedWorld3xit : FlxSprite;
    public var combinedWorld3Stone1 : FlxSprite;
    public var combinedWorld3Stone2 : FlxSprite;
    public var isExitOpen : Bool;

    // World 4
    public var combinedWorld4Stone1 : FlxSprite;
    public var combinedWorld4Stone2 : FlxSprite;

    public var refreshWorld1 : Bool;
    public var refreshWorld2 : Bool;
    public var refreshWorld3 : Bool;
    public var refreshWorld4 : Bool;

    public var timerText : FlxText;
    public var startTime : Float;

    /**
     * Function that is called up when to state is created to set it up. 
     */
    override public function create():Void
    {
        super.create();

        // Create the game text.
        var text : FlxText = new FlxText(0, 0, FlxG.width, "Level Sync v1.2");
        text.alignment = "right";
        add(text);

        startTime = FlxG.elapsed;



        timerText = new FlxText(0,16*1, FlxG.width, "Elapsed Time: 00:00:00");
        timerText.alignment = "right";
        add(timerText);

        level = new FlxTilemap();
        level.loadMap(Assets.getText("assets/data/level1.csv"), "assets/images/tiles.png", TILE_WIDTH, TILE_HEIGHT, FlxTilemap.OFF);
        add(level);

        var instructions : FlxSprite = new FlxSprite(420, 16*2);
        instructions.loadGraphic("assets/images/instructions.png", false);
        add(instructions);

        var combined : FlxSprite = new FlxSprite(11*16+4, 23*16);
        combined.loadGraphic("assets/images/combined.png", false);
        add(combined);

        setupButtons();
        setupGroups();

        setupWorld1();
        setupWorld2();
        setupWorld3();
        setupWorld4();

    }

    private function setupGroups():Void
    {        
        guards = new FlxTypedGroup<FlxSprite>();
        add(guards);

        crates = new FlxTypedGroup<FlxSprite>();
        add(crates);

        stones = new FlxTypedGroup<FlxSprite>();
        add(stones);

        keys = new FlxTypedGroup<FlxSprite>();
        add(keys);

        exits = new FlxTypedGroup<FlxSprite>();
        add(exits);
    }

    private function setupButtons() : Void 
    {
        buttons = new Array<FlxButton>();
        for (i in 0...4) {
            var buttonPoint : FlxPoint = getPositionFromTiles(0, 3+5*i);
            var button = new FlxButton( 320, buttonPoint.y , "Disconnected", onButtonClick.bind(i));
            button.color = FlxColor.RED;
            button.label.color = FlxColor.WHITE;
            buttons.push(button);
            add(button);
        }
        
    }

    private function onButtonClick(i : Int) : Void 
    {
        toggleButton(buttons[i]);

        if (i == 0) 
        {
            refreshWorld1 = true;
        }
        else if (i==1)
        {
            refreshWorld2 = true;
        }
        else if (i==2)
        {
            refreshWorld3 = true;
        }
          else if (i==3)
        {
            refreshWorld4 = true;
        }
    }

    private function refreshCombinedWorld(i : Int) : Void
    {
        if (i == 0) 
        {
            // Combine World 1
            if (buttons[i].text == "Connected")
            {
                onWorld1();
            }
            else 
            {
                offWorld1();
            }
        }
        else if (i==1)
        {
            // Combine World 2
            if (buttons[i].text == "Connected")
            {
                onWorld2();
            }
            else 
            {
                offWorld2();
            }
        }
        else if (i==2)
        {
            // Combine World 3
            if (buttons[i].text == "Connected")
            {
                onWorld3();
            }
            else 
            {
                offWorld3();
            }
        }
        else if (i==3)
        {
            // Combine World 3
            if (buttons[i].text == "Connected")
            {
                onWorld4();
            }
            else 
            {
                offWorld4();
            }
        }
    }

    private function onWorld1() : Void
    {
        // if (combinedGuard == null)
        // {
        combinedGuard = createGuard();
        // }
        setSpriteTilePosition(combinedGuard, 12+7, getCombinedTileY());
        combinedGuard.x += 10;
        combinedGuard.facing = world1Guard.facing;
        combinedGuard.flipX = world1Guard.flipX;
        combinedGuard.velocity.x = 0;
        combinedGuard.velocity.y = 0;
        guards.add(combinedGuard);

        combinedCrate1 = createCrate();
        setSpriteTilePosition(combinedCrate1, 12 + 5, getCombinedTileY());
        crates.add(combinedCrate1);
        combinedCrate2 = createCrate();
        setSpriteTilePosition(combinedCrate2, 12 + 10, getCombinedTileY());
        crates.add(combinedCrate2);
    }

    private function offWorld1() : Void
    {
        if (combinedGuard != null)
        {
            guards.remove(combinedGuard, true);
        }
        if (combinedCrate1 != null)
        {
            crates.remove(combinedCrate1, true);
        }
        if (combinedCrate2 != null)
        {
            crates.remove(combinedCrate2, true);
        }
    }

    private function onWorld2() : Void
    {
        combinedWorld2Key = createKey();
        setSpriteTilePosition(combinedWorld2Key, 12+2, getCombinedTileY() );
        keys.add(combinedWorld2Key);

        combinedWorld2Stone1 = createStone();
        setSpriteTilePosition(combinedWorld2Stone1, 12+8, getCombinedTileY());
        stones.add(combinedWorld2Stone1);

        combinedWorld2Stone2 = createStone();
        setSpriteTilePosition(combinedWorld2Stone2, 12+12, getCombinedTileY()+2);
        stones.add(combinedWorld2Stone2);

        combinedWorld2Stone3 = createStone();
        setSpriteTilePosition(combinedWorld2Stone3, 12+13, getCombinedTileY()+2);
        stones.add(combinedWorld2Stone3);
    }

    private function offWorld2() : Void
    {
        keys.remove(combinedWorld2Key, true);
        stones.remove(combinedWorld2Stone1, true);
        stones.remove(combinedWorld2Stone2, true);
        stones.remove(combinedWorld2Stone3, true);
    }

    private function onWorld3() : Void
    {
        combinedWorld3xit = createExit();
        setSpriteTilePosition(combinedWorld3xit, 12+14, getCombinedTileY());
        setDoorOpen(combinedWorld3xit, false);
        exits.add(combinedWorld3xit);

        // combinedWorld3Stone1 = createStone();
        // setSpriteTilePosition(combinedWorld3Stone1 , 12+4, getCombinedTileY());
        // stones.add(combinedWorld3Stone1);

        // combinedWorld3Stone2 = createStone();
        // setSpriteTilePosition(combinedWorld3Stone2, 12+11, getCombinedTileY());
        // stones.add(combinedWorld3Stone2);
    }

    private function offWorld3() : Void
    {
        exits.remove(combinedWorld3xit);
        setDoorOpen(world3Exit, false);
        combinedWorld3xit = null;
        isExitOpen = false;
        // stones.remove(combinedWorld3Stone1);
        // stones.remove(combinedWorld3Stone2);
    }

    private function onWorld4() : Void
    {
        combinedWorld4Stone1 = createStone();
        combinedWorld4Stone2 = createStone();

        setSpriteTilePosition(combinedWorld4Stone1, 12+2, getCombinedTileY()+2);
        setSpriteTilePosition(combinedWorld4Stone2, 12+3, getCombinedTileY()+2);

        stones.add(combinedWorld4Stone1);
        stones.add(combinedWorld4Stone2);
    }

    private function offWorld4() : Void
    {
        stones.remove(combinedWorld4Stone1);
        stones.remove(combinedWorld4Stone2);
    }

    private function getCombinedTileY() : Int
    {
        return 25;
    }

    private function getCombinedWorldY() : Int
    {
        return getCombinedTileY()*TILE_HEIGHT;
    }

    private function toggleButton(button : FlxButton) : Void
    {
        if (button.text == "Connected") 
        {
            button.text = "Disconnected";
            button.color = FlxColor.RED;
        }
        else 
        {
            button.text = "Connected";
            button.color = FlxColor.GREEN;
        }
    }

    private function createExit() : FlxSprite
    {
        // Create the _level exit
        var exit = new FlxSprite();
        exit.makeGraphic(14, 16, 0xFFFFFFFF);

        return exit;
    }

    private function createKey() : FlxSprite
    {
        // Create the _level exit
        var key = new FlxSprite();
        key.makeGraphic(2, 8, FlxColor.YELLOW);
        key.offset.set(7, -8);

        return key;
    }

    private function setupWorld1() : Void
    {
        world1Guard = createGuard();
        setSpriteTilePosition(world1Guard, 8 , 3);
        
        var crate1 = createCrate();
        var crate2 = createCrate();
        
        setSpriteTilePosition(crate1, 7,3);
        setSpriteTilePosition(crate2, 12,3);

        guards.add(world1Guard);
        crates.add(crate1);
        crates.add(crate2);
    }

    private function setupWorld2() : Void
    {
        var key = createKey();
        setSpriteTilePosition(key, 2+2, 8);
        keys.add(key);

        var stone1 = createStone();
        setSpriteTilePosition(stone1, 2+8, 8);
        stones.add(stone1);

        var stone2 = createStone();
        setSpriteTilePosition(stone2, 2+12, 10);
        stones.add(stone2);

        var stone3 = createStone();
        setSpriteTilePosition(stone3, 2+13, 10);
        stones.add(stone3);

    }

    private function setupWorld3() : Void
    {
        world3Exit = createExit();
        setSpriteTilePosition(world3Exit, 2+14, 13);
        setDoorOpen(world3Exit, false);
        exits.add(world3Exit);

        // var stone1 = createStone();
        // setSpriteTilePosition(stone1, 2+4, 13);
        // stones.add(stone1);

        // var stone2 = createStone();
        // setSpriteTilePosition(stone2, 2+11, 13);
        // stones.add(stone2);
    }

    private function setupWorld4() : Void
    {
        var stone4_0 = createStone();
        setSpriteTilePosition(stone4_0, 2+2, 18+2);
        stones.add(stone4_0);

        var stone4_1 = createStone();
        setSpriteTilePosition(stone4_1, 2+3, 18+2);
        stones.add(stone4_1);

    }

    private function createCrate() : FlxSprite
    {
        var crate = new FlxSprite();
        crate.loadGraphic("assets/images/crate.png", false, 16);
        crate.setSize(16,16);

        crate.acceleration.y = 420;
        crate.drag.x = 35;
        crate.maxVelocity.set(150,150);
        return crate;
    }

    private function createStone() : FlxSprite
    {
        var stone = new FlxSprite();
        stone.solid = true;
        stone.immovable = true;
        stone.loadGraphic("assets/images/stone.png", false, 16);
        return stone;
    }

    private function createGuard() : FlxSprite 
    {
        var guard = new FlxSprite();
        guard.loadGraphic("assets/images/hero.png", true, 16);
        
        // Bounding box tweaks
        guard.setSize(14, 14);
        guard.offset.set(1, 1);
        guard.facing = FlxObject.RIGHT;

        // Basic guard physics
        // guard.drag.x = 640;
        guard.acceleration.y = 420;
        guard.maxVelocity.set(120, 200);
        
        // Animations
        guard.animation.add("idle", [0]);
        guard.animation.add("run", [1, 2, 3, 0], 12);
        guard.animation.add("jump", [4]);

        return guard;
    }

    private function updateGuards():Void
    {
        for (player in guards.members) {

            // FlxSpriteUtil.screenWrap(player);
            
            // MOVEMENT
            if (player.facing == FlxObject.RIGHT) {
                player.velocity.x = 50;
            }
            else if (player.facing == FlxObject.LEFT) {
                player.velocity.x = -50;
            }

            if (!player.flipX && player.justTouched( FlxObject.RIGHT )) {
                if (player != combinedGuard || (player == combinedGuard && !isCombinedGuardOnCrate))
                {
                    player.flipX = true;
                    player.facing = FlxObject.LEFT;
                }
                
            }
            else  if (player.flipX && player.justTouched( FlxObject.LEFT) )
            {
                if (player != combinedGuard || (player == combinedGuard && !isCombinedGuardOnCrate))
                {
                    player.flipX = false;
                    player.facing = FlxObject.RIGHT;
                }
            }

            // ANIMATION
            if (player.velocity.y != 0)
            {
                player.animation.play("jump");
            }
            else if (player.velocity.x == 0)
            {
                player.animation.play("idle");
            }
            else
            {
                player.animation.play("run");
            }

        }

        // player.acceleration.x = 0; 
        // if (FlxG.keys.anyPressed(["LEFT", "A"]))
        // {
        //     player.flipX = true;
        //     player.acceleration.x -= player.drag.x;
        // }
        // else if (FlxG.keys.anyPressed(["RIGHT", "D"]))
        // {
        //     player.flipX = false;
        //     player.acceleration.x += player.drag.x;
        // }
        // if (FlxG.keys.anyJustPressed(["UP", "W"]) && player.velocity.y == 0)
        // {
        //     player.y -= 1;
        //     player.velocity.y = -200;
        // }
        
        
    }

    private function setDoorOpen(door : FlxSprite, open : Bool)
    {
        if (open)
        {
            door.color = FlxColor.GREEN;
        }
        else
        {
            door.color = FlxColor.RED;
        }
    }

    private function updateCrates():Void
    {
        
    }

    private function getPositionFromTiles(tileX : Int, tileY : Int)  : FlxPoint
    {
        return new FlxPoint(tileX*TILE_WIDTH,tileY*TILE_HEIGHT);
    }

    private function setSpriteTilePosition(sprite : FlxSprite, tileX : Int, tileY : Int) : Void
    {
        var position : FlxPoint = new FlxPoint(tileX*TILE_WIDTH,tileY*TILE_HEIGHT);   
        sprite.setPosition(position.x, position.y);
    }

    private function refreshWorlds() : Void
    {
        if (refreshWorld1)
        {
            refreshCombinedWorld(0);
            refreshWorld1 = false;
        }
        if (refreshWorld2)
        {
            refreshCombinedWorld(1);
            refreshWorld2 = false;
        }
        if (refreshWorld3)
        {
            refreshCombinedWorld(2);
            refreshWorld3 = false;
        }
        if (refreshWorld4)
        {
            refreshCombinedWorld(3);
            refreshWorld4 = false;
        }
    }
    
    /**
     * Function that is called when this state is destroyed - you might want to 
     * consider setting all objects this state uses to null to help garbage collection.
     */
    override public function destroy():Void
    {
        super.destroy();
    }

    private function onGuardCollideCrate(guard : FlxSprite, crate : FlxSprite)
    {
        if (crate.isTouching(FlxObject.CEILING)) 
        {
            isCombinedGuardOnCrate = true;
            guard.y--;
        }
        else
        {
             isCombinedGuardOnCrate = false;
        }
    }

    private function onGuardCollideKey(guard : FlxSprite, key : FlxSprite)
    {
        for (key in keys) 
        {
            if (key == combinedWorld2Key)
            {
                key.exists = false;
            }
        }
        for (exit in exits)
        {
            if (exit == combinedWorld3xit)
            {
                isExitOpen = true;
            }
            setDoorOpen(exit, true);
        }

    }

    private function onGuardOverlapExit(guard : FlxSprite, exit : FlxSprite)
    {
        // trace("onGuardOverlapExit, exit.color=" + exit.color);
        // trace("onGuardOverlapExit, white.color=" + FlxColor.WHITE);
        // trace("onGuardOverlapExit, green.color=" + FlxColor.GREEN);

        if (isExitOpen)
        {
            WinState.timeText = getTimeString();
            FlxG.switchState(new WinState());
        }
    }

    private function updateTimer() : Void
    {
        startTime += FlxG.elapsed;
        timerText.text = "Time: " + getTimeString();

    }

    private function getTimeString() : String
    {
        var totalTime = startTime;

        var seconds = Math.floor(totalTime  % 60);
        totalTime = Math.floor(totalTime / 60);


        var mins = Math.floor(totalTime % 60);
        var hours = Math.floor(totalTime/60);

        var timestring = (hours < 10 ? "0" : "") + hours + ":" + 
                         (mins < 10 ? "0" : "") + mins + ":" +
                         (seconds < 10 ? "0" : "") + seconds;  

        return timestring;
    }

    /**
     * Function that is called once every frame.
     */
    override public function update():Void
    {
        // Tilemaps can be collided just like any other FlxObject, and flixel
        // automatically collides each individual tile with the object.
        FlxG.collide(guards, level);
        FlxG.collide(guards, stones);
        FlxG.collide(guards, keys, onGuardCollideKey);
        
        if (!FlxG.collide(guards, crates, onGuardCollideCrate)) 
        {
            isCombinedGuardOnCrate = false;
        }

        FlxG.collide(crates, crates);
        FlxG.collide(crates, level);
        FlxG.collide(crates, stones);

        FlxG.overlap(guards, exits, onGuardOverlapExit);

        updateGuards();
        updateCrates();

        refreshWorlds();

        updateTimer();

        super.update();
    }   
}