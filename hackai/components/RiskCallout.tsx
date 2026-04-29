import type { ReactNode } from "react";
import { cn } from "@/lib/utils";

type CalloutVariant = "danger" | "warn" | "info" | "success";

interface RiskCalloutProps {
  variant?: CalloutVariant;
  title?: string;
  children: ReactNode;
  className?: string;
}

const variantConfig: Record<
  CalloutVariant,
  { container: string; icon: string; title: string; iconPath: string }
> = {
  danger: {
    container:
      "bg-red-500/5 border-red-500/30 dark:bg-red-500/10",
    icon: "text-red-500",
    title: "text-red-600 dark:text-red-400",
    iconPath:
      "M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126zM12 15.75h.007v.008H12v-.008z",
  },
  warn: {
    container:
      "bg-yellow-500/5 border-yellow-500/30 dark:bg-yellow-500/10",
    icon: "text-yellow-500",
    title: "text-yellow-700 dark:text-yellow-400",
    iconPath:
      "M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126zM12 15.75h.007v.008H12v-.008z",
  },
  info: {
    container:
      "bg-blue-500/5 border-blue-500/30 dark:bg-blue-500/10",
    icon: "text-blue-500",
    title: "text-blue-700 dark:text-blue-400",
    iconPath:
      "M11.25 11.25l.041-.02a.75.75 0 011.063.852l-.708 2.836a.75.75 0 001.063.853l.041-.021M21 12a9 9 0 11-18 0 9 9 0 0118 0zm-9-3.75h.008v.008H12V8.25z",
  },
  success: {
    container:
      "bg-green-500/5 border-green-500/30 dark:bg-green-500/10",
    icon: "text-green-500",
    title: "text-green-700 dark:text-green-400",
    iconPath: "M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z",
  },
};

export function RiskCallout({
  variant = "warn",
  title,
  children,
  className,
}: RiskCalloutProps) {
  const config = variantConfig[variant];

  return (
    <div
      role="note"
      className={cn(
        "rounded-lg border px-4 py-4 flex gap-3",
        config.container,
        className
      )}
    >
      <svg
        className={cn("h-5 w-5 flex-shrink-0 mt-0.5", config.icon)}
        fill="none"
        viewBox="0 0 24 24"
        strokeWidth="1.5"
        stroke="currentColor"
        aria-hidden="true"
      >
        <path strokeLinecap="round" strokeLinejoin="round" d={config.iconPath} />
      </svg>
      <div className="text-sm leading-relaxed">
        {title && (
          <p className={cn("font-semibold mb-1", config.title)}>{title}</p>
        )}
        <div className="text-muted-foreground">{children}</div>
      </div>
    </div>
  );
}
