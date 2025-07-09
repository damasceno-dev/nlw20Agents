
// Format date from ISO string to relative time in Portuguese BR
// Shows days and hours for time differences >= 1 hour, and minutes for < 1 hour
export function formatDate(dateString: string | undefined): string {
    if (!dateString) {
        return "data inválida";
    }

    const date = new Date(dateString);
    const now = new Date();

    // Calculate time difference in milliseconds
    const diffMs = date.getTime() - now.getTime();
    const isFuture = diffMs > 0;

    // Convert to absolute difference
    const diffAbsMs = Math.abs(diffMs);

    // If less than a minute, return "agora mesmo"
    if (diffAbsMs < 60_000) {
        return "agora mesmo";
    }

    return formatRelativeTime(diffAbsMs, isFuture);
}

// Helper function to format time units with proper pluralization
function formatTimeUnit(value: number, singular: string, plural: string): string {
    return `${value} ${value === 1 ? singular : plural}`;
}

// Helper function to format the relative time string
function formatRelativeTime(diffMs: number, isFuture: boolean): string {
    const diffMinutesTotal = diffMs / (1000 * 60);

    // Calculate days, hours, and minutes
    const diffDays = Math.floor(diffMinutesTotal / (24 * 60));
    const diffHours = Math.floor((diffMinutesTotal % (24 * 60)) / 60);
    const diffMinutes = Math.floor(diffMinutesTotal % 60);

    const prefix = isFuture ? "daqui a " : "há ";

    // Format based on the time difference
    if (diffDays > 0) {
        return formatDaysAndHours(diffDays, diffHours, prefix);
    }if (diffHours > 0) {
        return `${prefix}${formatTimeUnit(diffHours, "hora", "horas")}`;
    }
        return `${prefix}${formatTimeUnit(diffMinutes, "minuto", "minutos")}`;
}

// Helper function to format days and hours
function formatDaysAndHours(days: number, hours: number, prefix: string): string {
    const daysFormatted = formatTimeUnit(days, "dia", "dias");

    if (hours > 0) {
        const hoursFormatted = formatTimeUnit(hours, "hora", "horas");
        return `${prefix}${daysFormatted} e ${hoursFormatted}`;
    }

    return `${prefix}${daysFormatted}`;
}
