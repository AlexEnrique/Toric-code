module utils.progress_bar;

import std.format : format;
import std.conv : to;
import progress;


class ProgressBar : IncrementalBar
{
    this(string msg, size_t max)
    {
        super();
        this.max = max;
        fill = "#";
        message = { return msg; };
        suffix = {
            string message;
            message ~= "%.2f".format(this.percent) ~ "%";
            message ~= "\nRemaining time: " ~ this.remainingTime;

            return message;
        };
    }

    this(string msg)
    {
        super();
        fill = "#";
        message = { return msg; };
        suffix = {
            string message;
            message ~= "%.2f".format(this.percent) ~ "%";
            message ~= "\nRemaining time: " ~ this.remainingTime;

            return message;
        };
    }

    private string remainingTime() @property
    {
        long days;
        long hours;
        long minutes;
        long seconds;

        this.eta.split!("days", "hours", "minutes", "seconds")(days, hours, minutes, seconds);

        string time;
        if (days > 0)
        {
            time ~= "%dd".format(days);
        }
        if (hours > 0)
        {
            time ~= "%dh".format(hours);
        }
        if (minutes > 0)
        {
            time ~= "%dm".format(minutes);
        }
        time ~= "%ds".format(seconds);

        return time;
    }
}
