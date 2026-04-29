/**
 * ReferenceCard — 개별 참조 자료 카드 컴포넌트.
 *
 * references/page.tsx의 인라인 렌더링을 추출.
 * 독립 컴포넌트로 분리하여 단독 테스트 및 재사용 가능.
 */

import { SectionCard } from "@/components/SectionCard";
import { Badge } from "@/components/Badge";

export interface Reference {
  id: string;
  title: string;
  source: string;
  year: string;
  type: "paper" | "standard" | "blog" | "cve" | "video";
  url?: string;
  description: string;
}

const TYPE_LABEL: Record<Reference["type"], string> = {
  paper:    "논문",
  standard: "표준",
  blog:     "블로그",
  cve:      "CVE",
  video:    "영상",
};

interface ReferenceCardProps {
  reference: Reference;
  className?: string;
}

export function ReferenceCard({ reference, className }: ReferenceCardProps) {
  const { title, source, year, type, url, description } = reference;

  return (
    <SectionCard variant="bordered" className={className}>
      {/* Meta row */}
      <div className="flex flex-wrap items-start gap-2 mb-2">
        <Badge variant="outline">{TYPE_LABEL[type]}</Badge>
        <span className="text-xs text-muted-foreground">{year}</span>
        <span className="text-xs text-muted-foreground" aria-hidden="true">—</span>
        <span className="text-xs text-muted-foreground">{source}</span>
      </div>

      {/* Title — linked if URL available */}
      <h2 className="text-sm font-semibold text-foreground mb-2 leading-snug">
        {url ? (
          <a
            href={url}
            target="_blank"
            rel="noopener noreferrer"
            className="hover:text-blue-500 transition-colors underline underline-offset-2"
            aria-label={`${title} (새 탭에서 열림)`}
          >
            {title} ↗
          </a>
        ) : (
          title
        )}
      </h2>

      {/* Description */}
      <p className="text-sm text-muted-foreground leading-relaxed">
        {description}
      </p>
    </SectionCard>
  );
}
