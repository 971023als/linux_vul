import type { ReactNode } from "react";
import { cn } from "@/lib/utils";

interface SectionCardProps {
  children: ReactNode;
  className?: string;
  variant?: "default" | "muted" | "bordered";
}

export function SectionCard({
  children,
  className,
  variant = "default",
}: SectionCardProps) {
  return (
    <div
      className={cn(
        "rounded-xl p-6",
        variant === "default" && "bg-muted/40",
        variant === "muted" && "bg-muted/70",
        variant === "bordered" && "border border-border bg-background",
        className
      )}
    >
      {children}
    </div>
  );
}

interface SectionTitleProps {
  children: ReactNode;
  as?: "h2" | "h3";
  id?: string;
  className?: string;
}

export function SectionTitle({
  children,
  as: Tag = "h2",
  id,
  className,
}: SectionTitleProps) {
  return (
    <Tag
      id={id}
      className={cn(
        "font-bold tracking-tight text-foreground",
        Tag === "h2" ? "text-2xl sm:text-3xl" : "text-xl sm:text-2xl",
        className
      )}
    >
      {children}
    </Tag>
  );
}
