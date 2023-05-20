import Toybox.Activity;
import Toybox.Lang;
import Toybox.Sensor;
import Toybox.Time;
import Toybox.WatchUi;

class BeersBurnedView extends WatchUi.SimpleDataField {
    const BEER_CALORIES = 275;

    // Set the label of the data field here.
    function initialize() {
        SimpleDataField.initialize();
        label = "Beers earned";
    }

    /**
        Calculate calories burned into beers (assuming BEER_CALLORIES for one buttle)
    */

    function compute(info as Activity.Info) as Numeric or Duration or String or Null {
        var beersEarned = 0;
        if (info.calories != null) {
            try {
                beersEarned = info.calories.toFloat() / BEER_CALORIES;
            }
            catch (e instanceof Lang.Exception) {}
        }
        return beersEarned;
    }
}