import type { ReactNode } from "react";
import { cn } from "@/lib/utils";

type BadgeVariant = "default" | "outline" | "danger" | "warn" | "success";

interface BadgeProps {
  children: ReactNode;
  variant?: BadgeVariant;
  className?: string;
}

const variantClasses: Record<BadgeVariant, string> = {
  default:
    "bg-blue-500/10 text-blue-400 ring-1 ring-blue-500/20",
  outline:
    "bg-transparent text-muted-foreground ring-1 ring-border",
  danger:
    "bg-red-500/10 text-red-400 ring-1 ring-red-500/20",
  warn:
    "bg-yellow-500/10 text-yellow-500 ring-1 ring-yellow-500/20",
  success:
    "bg-green-500/10 text-green-400 ring-1 ring-green-500/20",
};

export function Badge({ children, variant = "default", className }: BadgeProps) {
  return (
    <span
      className={cn(
        "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium",
        variantClasses[variant],
        className
      )}
    >
      {children}
    </span>
  );
}

/** Risk level badge — maps "high" | "medium" | "low" to semantic colors */
export function RiskBadge({ level }: { level: "high" | "medium" | "low" }) {
  const map = {
    high: { variant: "danger" as BadgeVariant, label: "위험도 높음" },
    medium: { variant: "warn" as BadgeVariant, label: "위험도 중간" },
    low: { variant: "success" as BadgeVariant, label: "위험도 낮음" },
  };
  const { variant, label } = map[level];
  return <Badge variant={variant}>{label}</Badge>;
}

/** APTS category badge */
export function AptsBadge({ category }: { category: string }) {
  return (
    <Badge variant="outline" className="font-mono">
      {category}
    </Badge>
  );
}
