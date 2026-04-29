"use client";

import { useState } from "react";
import { type FaqItem } from "@/data/faq";
import { cn } from "@/lib/utils";

interface FaqListProps {
  items: FaqItem[];
  className?: string;
}

export function FaqList({ items, className }: FaqListProps) {
  return (
    <dl className={cn("space-y-3", className)}>
      {items.map((item) => (
        <FaqAccordion key={item.id} item={item} />
      ))}
    </dl>
  );
}

function FaqAccordion({ item }: { item: FaqItem }) {
  const [isOpen, setIsOpen] = useState(false);
  const panelId = `faq-panel-${item.id}`;
  const buttonId = `faq-button-${item.id}`;

  return (
    <div
      className="rounded-lg border border-border bg-background overflow-hidden"
      data-testid={`faq-item-${item.id}`}
    >
      <dt>
        <button
          id={buttonId}
          type="button"
          className="flex w-full items-center justify-between px-5 py-4 text-left text-sm font-medium text-foreground hover:bg-muted/50 transition-colors"
          aria-expanded={isOpen}
          aria-controls={panelId}
          onClick={() => setIsOpen((prev) => !prev)}
        >
          <span>{item.question}</span>
          <svg
            className={cn(
              "h-4 w-4 flex-shrink-0 text-muted-foreground transition-transform duration-200",
              isOpen && "rotate-180"
            )}
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
            aria-hidden="true"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M19 9l-7 7-7-7"
            />
          </svg>
        </button>
      </dt>
      <dd
        id={panelId}
        role="region"
        aria-labelledby={buttonId}
        className={cn(
          "overflow-hidden transition-all duration-200",
          isOpen ? "max-h-[500px]" : "max-h-0"
        )}
      >
        <div className="px-5 pb-4 pt-0 text-sm text-muted-foreground leading-relaxed border-t border-border">
          <p className="mt-3">{item.answer}</p>
          {item.reference && (
            <p className="mt-2 text-xs text-muted-foreground/60">
              참조:{" "}
              <a
                href={item.reference}
                target="_blank"
                rel="noopener noreferrer"
                className="underline hover:text-foreground"
              >
                {item.reference}
              </a>
            </p>
          )}
        </div>
      </dd>
    </div>
  );
}
