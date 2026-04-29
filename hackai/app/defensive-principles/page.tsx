import type { Metadata } from "next";
import { PageContainer, PageHeader } from "@/components/PageContainer";
import { SectionCard } from "@/components/SectionCard";
import { Badge } from "@/components/Badge";
import { defensivePrinciples } from "@/data/defensive-principles";
import { filterValid, isDefensivePrinciple } from "@/lib/guards";
import { groupBy } from "@/lib/utils";
import { logger } from "@/lib/debug";

export const metadata: Metadata = {
  title: "방어 원칙 — Madhat Labs",
  description: "AI 에이전트 시스템을 위한 11가지 방어 원칙",
};

const tierLabel: Record<string, string> = {
  foundational: "기초",
  operational: "운영",
  advanced: "고급",
};

const tierVariant: Record<string, "default" | "warn" | "danger"> = {
  foundational: "default",
  operational: "warn",
  advanced: "danger",
};

/** Render order for tier groups */
const TIER_ORDER = ["foundational", "operational", "advanced"] as const;
const TIER_LABEL: Record<string, string> = {
  foundational: "기초 원칙",
  operational:  "운영 원칙",
  advanced:     "고급 원칙",
};

export default function DefensivePrinciplesPage() {
  const validPrinciples = filterValid(defensivePrinciples, isDefensivePrinciple, "DefensivePrinciple");

  if (validPrinciples.length !== defensivePrinciples.length) {
    logger.warn(
      "DefensivePrinciplesPage",
      `${defensivePrinciples.length - validPrinciples.length}개 방어 원칙이 유효성 검사를 통과하지 못했습니다.`
    );
  }

  const byTier = groupBy(validPrinciples, (p) => p.tier);

  const groups = TIER_ORDER.map((tier) => ({
    tier,
    label: TIER_LABEL[tier],
    items: byTier[tier] ?? [],
  }));

  return (
    <PageContainer>
      <PageHeader
        title="방어 원칙"
        description="AI 에이전트 시스템 설계와 운영에서 적용해야 할 11가지 방어 원칙입니다."
        badge="Defensive Principles"
      />

      {groups.map(({ tier, label, items }) =>
        items.length > 0 ? (
          <section key={tier} className="mb-12" aria-labelledby={`${tier}-heading`}>
            <h2
              id={`${tier}-heading`}
              className="text-lg font-semibold text-foreground mb-5 flex items-center gap-2"
            >
              {label}
              <Badge variant={tierVariant[tier]}>{tierLabel[tier]}</Badge>
            </h2>
            <div className="space-y-4">
              {items.map((principle) => (
                <SectionCard key={principle.id} variant="bordered">
                  <div className="flex items-start gap-4">
                    <span
                      className="text-3xl font-bold text-blue-500/30 font-mono leading-none flex-shrink-0 select-none"
                      aria-hidden="true"
                    >
                      {String(principle.number).padStart(2, "0")}
                    </span>
                    <div className="flex-1 min-w-0">
                      <h3 className="text-base font-semibold text-foreground mb-1">
                        {principle.title}
                      </h3>
                      <p className="text-sm text-muted-foreground leading-relaxed mb-3">
                        {principle.summary}
                      </p>
                      <p className="text-sm text-muted-foreground/80 leading-relaxed mb-4">
                        {principle.detail}
                      </p>
                      <div className="border-t border-border pt-3">
                        <p className="text-xs font-medium text-foreground/70 mb-2">
                          실천 방법
                        </p>
                        <ul className="space-y-1">
                          {principle.practices.map((practice) => (
                            <li
                              key={practice}
                              className="flex gap-2 text-xs text-muted-foreground"
                            >
                              <span className="text-blue-500 flex-shrink-0" aria-hidden="true">›</span>
                              {practice}
                            </li>
                          ))}
                        </ul>
                      </div>
                      {principle.aptsRelevance && principle.aptsRelevance.length > 0 && (
                        <div className="mt-3 flex flex-wrap gap-1.5">
                          {principle.aptsRelevance.map((cat) => (
                            <Badge key={cat} variant="outline" className="text-[11px] font-mono">
                              APTS·{cat}
                            </Badge>
                          ))}
                        </div>
                      )}
                    </div>
                  </div>
                </SectionCard>
              ))}
            </div>
          </section>
        ) : null
      )}
    </PageContainer>
  );
}
