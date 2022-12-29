import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class CasioF91W_watchfaceView extends WatchUi.WatchFace {
    var bgImage;
    var fntLCDLarge, fntLCDSmall;
    var centerX, centerY, imgOffsetX, imgOffsetY;
    var viewHours, viewSeparator, viewMinutes, viewSeconds, viewMonth, viewDay;
    static const weekDays = ["SU", "MO", "TU", "WE", "TH", "FR", "SA"];
    var inSleep = false;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));

        // Image calculations
        bgImage = Application.loadResource(Rez.Drawables.Background) as BitmapResource;
        centerX = dc.getWidth() / 2;
        imgOffsetX = centerX - bgImage.getWidth() / 2;
        centerY = dc.getHeight() / 2; 
        imgOffsetY = centerY - bgImage.getHeight() / 2;

        // LCD fonts
        fntLCDLarge = Application.loadResource(Rez.Fonts.LCDFontsLarge) as FontResource;
        fntLCDSmall = Application.loadResource(Rez.Fonts.LCDFontsSmall) as FontResource;

        // layout elements
        viewHours = View.findDrawableById("HoursLabel") as Text;
        viewSeparator = View.findDrawableById("SeparatorLabel") as Text;
        viewMinutes = View.findDrawableById("MinutesLabel") as Text;
        viewSeconds = View.findDrawableById("SecondsLabel") as Text;
        viewMonth = View.findDrawableById("MonthLabel") as Text;
        viewDay = View.findDrawableById("DayLabel") as Text;
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        // Draw background F-91W
        dc.drawBitmap(imgOffsetX, imgOffsetY, bgImage);

        // Draw data on LCD display

        // hours:minutes
        var timeAndDate = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);

        viewHours.setText(timeAndDate.hour.format("%d"));
        viewMinutes.setText(timeAndDate.min.format("%02d"));

        // month and day
        viewMonth.setText(timeAndDate.day.format("%d"));
        viewDay.setText(weekDays[(timeAndDate.day_of_week - Time.Gregorian.DAY_SUNDAY) % 7]);

        // draw LCD
        viewHours.draw(dc);
        viewSeparator.draw(dc);
        viewMinutes.draw(dc);
        viewMonth.draw(dc);
        viewDay.draw(dc);

        if (!inSleep) {
            // seconds
            viewSeconds.setText(timeAndDate.sec.format("%02d"));
            viewSeconds.draw(dc);
        }
    }

    // Update the view (every second)
    function onPartialUpdate(dc as Dc) as Void {
        onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
        inSleep = false;
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
        inSleep = true;
    }

}
