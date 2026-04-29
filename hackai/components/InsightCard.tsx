import { type Insight } from "@/data/insights";
import { RiskBadge, AptsBadge, Badge } from "@/components/Badge";
import { cn } from "@/lib/utils";

interface InsightCardProps {
  insight: Insight;
  className?: string;
}

export function InsightCard({ insight, className }: InsightCardProps) {
  return (
    <article
      className={cn(
        "rounded-xl border border-border bg-background p-5 transition-shadow hover:shadow-md",
        className
      )}
      aria-labelledby={`insight-title-${insight.id}`}
      data-testid={`insight-card-${insight.id}`}
      data-risk={insight.risk}
      data-apts={insight.apts}
    >
      {/* Header row */}
      <div className="flex flex-wrap items-start gap-2 mb-3">
        <RiskBadge level={insight.risk} />
        <AptsBadge category={insight.apts} />
      </div>

      {/* Title */}
      <h3
        id={`insight-title-${insight.id}`}
        className="text-base font-semibold text-foreground leading-snug mb-2"
      >
        {insight.title}
      </h3>

      {/* Summary */}
      <p className="text-sm text-muted-foreground leading-relaxed mb-3">
        {insight.summary}
      </p>

      {/* Detail (collapsible-style, always visible on card) */}
      <p className="text-sm text-muted-foreground/80 leading-relaxed border-t border-border pt-3">
        {insight.detail}
      </p>

      {/* Tags */}
      {insight.tags.length > 0 && (
        <div className="mt-3 flex flex-wrap gap-1.5" aria-label="태그">
          {insight.tags.map((tag) => (
            <Badge key={tag} variant="outline" className="text-[11px]">
              {tag}
            </Badge>
          ))}
        </div>
      )}

      {/* Reference */}
      {insight.reference && (
        <p className="mt-3 text-xs text-muted-foreground/60">
          참조: {insight.reference}
        </p>
      )}
    </article>
  );
}
