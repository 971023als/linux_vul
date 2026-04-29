import { cn, formatDate } from "@/lib/utils";

export interface TimelineItem {
  id: string;
  date: string;
  title: string;
  description?: string;
  badge?: string;
}

interface TimelineProps {
  items: TimelineItem[];
  className?: string;
}

export function Timeline({ items, className }: TimelineProps) {
  return (
    <ol className={cn("relative border-l border-border ml-3", className)} aria-label="타임라인">
      {items.map((item, index) => (
        <li key={item.id} className={cn("mb-8 ml-6", index === items.length - 1 && "mb-0")}>
          {/* Dot */}
          <span
            className="absolute -left-[9px] flex h-4 w-4 items-center justify-center rounded-full bg-blue-500/20 ring-2 ring-blue-500/40"
            aria-hidden="true"
          >
            <span className="h-2 w-2 rounded-full bg-blue-500" />
          </span>

          <div>
            <time
              dateTime={item.date}
              className="text-xs font-medium text-muted-foreground"
            >
              {formatDate(item.date)}
            </time>
            {item.badge && (
              <span className="ml-2 inline-flex items-center rounded-full bg-blue-500/10 px-2 py-0.5 text-xs font-medium text-blue-400">
                {item.badge}
              </span>
            )}
            <h3 className="mt-1 text-sm font-semibold text-foreground">
              {item.title}
            </h3>
            {item.description && (
              <p className="mt-1 text-sm text-muted-foreground leading-relaxed">
                {item.description}
              </p>
            )}
          </div>
        </li>
      ))}
    </ol>
  );
}
