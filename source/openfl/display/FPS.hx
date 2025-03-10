package openfl.display;

import haxe.Timer;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;
import flixel.math.FlxMath;
import flixel.util.FlxStringUtil;
#if gl_stats
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;
#end
#if flash
import openfl.Lib;
#end

#if openfl
import openfl.system.System;
#end

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class FPS extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;

	public var memoryUsage:String = '';

	@:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat("Px437 IBM VGA 8x16", 16, color);
		autoSize = LEFT;
		multiline = true;
		text = "FPS: ";

		cacheCount = 0;
		currentTime = 0;
		times = [];

		#if flash
		addEventListener(Event.ENTER_FRAME, function(e)
		{
			var time = Lib.getTimer();
			__enterFrame(time - currentTime);
		});
		#end
	}

	// Event Handlers
	@:noCompletion
	private #if !flash override #end function __enterFrame(deltaTime:Float):Void
	{
		currentTime += deltaTime;
		times.push(currentTime);

		while (times[0] < currentTime - 1000)
		{
			times.shift();
		}

		var currentCount = times.length;
		currentFPS = Math.round((currentCount + cacheCount) / 2);
		if (currentFPS > ClientPrefs.framerate) currentFPS = ClientPrefs.framerate;

		if (currentCount != cacheCount /*&& visible*/)
		{
			text = "FPS: " + currentFPS;
			var memoryBytes:Float = 0;
			var memoryMegas:Float = 0;
			var memoryGigas:Float = 0;
			var memoryTeras:Float = 0;
			
			#if openfl
			memoryBytes = Math.abs(FlxMath.roundDecimal(System.totalMemory / 1000, 1));
			memoryMegas = Math.abs(FlxMath.roundDecimal(System.totalMemory / 1000000, 1));
			memoryGigas = Math.abs(FlxMath.roundDecimal(System.totalMemory / 1000000000, 1));
			memoryTeras = Math.abs(FlxMath.roundDecimal(System.totalMemory / 1000000000000, 1));
			
			text += "\nMemory: " + memoryMegas + " MB"; //someday i need to fix this bullshit
			/*if(memoryMegas > 0)
				text += "\nMemory: " + memoryMegas + " MB";
			if(memoryMegas > 1024)
				text += "\nMemory: " + memoryGigas + " GB";
			if(memoryMegas > 1000000)
				text += "\nMemory: " + memoryTeras + " TB";
			if(memoryMegas > 10000000)
				text += "\nMemory: " + memoryBytes + " Bytes";-*/
			/*if (memoryMegas >= 0xFFFFFFFF)
				memoryUsage += (Math.round(cast(memoryMegas, Float) / 0x400 / 0x400 / 0x400 * 1000) / 1000) + " GB";
			else if (memoryMegas >= 0x100000)
				memoryUsage += (Math.round(cast(memoryMegas, Float) / 0x400 / 0x400 * 1000) / 1000) + " MB";
			else if (memoryMegas >= 0x400)
				memoryUsage += (Math.round(cast(memoryMegas, Float) / 0x400 * 1000) / 1000) + " KB";
			else
				memoryUsage += memoryMegas + " B";*/
			#end

			textColor = 0xFFFFFFFF;
			if (memoryMegas > 3072 || currentFPS <= ClientPrefs.framerate / 2)
			{
				textColor = 0xFFFF0000;
			}

			#if (gl_stats && !disable_cffi && (!html5 || !canvas))
			text += "\ntotalDC: " + Context3DStats.totalDrawCalls();
			text += "\nstageDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE);
			text += "\nstage3DDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D);
			#end

			text += "\n";
		}

		cacheCount = currentCount;
	}
}
