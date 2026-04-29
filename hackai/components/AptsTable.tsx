/**
 * AptsTable — OWASP APTS 8개 도메인 커버리지 테이블.
 *
 * governance/page.tsx에서 추출. 독립 컴포넌트로 분리하여:
 *  - 단독으로 테스트 가능
 *  - 다른 페이지에서도 재사용 가능
 *  - governance page의 복잡도 감소
 */

import { Badge } from "@/components/Badge";

export interface AptsCategory {
  code: string;
  name: string;
  tier: string;
}

interface AptsTableProps {
  categories: AptsCategory[];
  className?: string;
}

export const APTS_CATEGORIES = [
  { code: "SE", name: "시스템 탈출 (System Escape)",          tier: "Tier 1-2" },
  { code: "SC", name: "비밀 탈취 (Secret Compromise)",        tier: "Tier 1-2" },
  { code: "HO", name: "운영 방해 (Hostile Operation)",        tier: "Tier 1-2" },
  { code: "AL", name: "에이전트 레이어 공격 (Agent Layer Attack)", tier: "Tier 1-3" },
  { code: "AR", name: "아키텍처 악용 (Architecture Abuse)",   tier: "Tier 1-3" },
  { code: "MR", name: "모니터링 회피 (Monitoring Resistance)", tier: "Tier 1-2" },
  { code: "TP", name: "신뢰 오염 (Trust Poisoning)",          tier: "Tier 1-3" },
  { code: "RP", name: "응답 조작 (Response Pollution)",       tier: "Tier 1-2" },
] satisfies AptsCategory[];

export function AptsTable({ categories, className }: AptsTableProps) {
  if (categories.length === 0) {
    return (
      <p className="text-sm text-muted-foreground">
        표시할 APTS 카테고리가 없습니다.
      </p>
    );
  }

  return (
    <div className={className}>
      <div className="overflow-x-auto">
        <table className="w-full text-sm border-collapse">
          <thead>
            <tr className="border-b border-border">
              <th
                scope="col"
                className="text-left py-2 pr-4 text-xs font-medium text-muted-foreground uppercase tracking-wider"
              >
                코드
              </th>
              <th
                scope="col"
                className="text-left py-2 pr-4 text-xs font-medium text-muted-foreground uppercase tracking-wider"
              >
                도메인
              </th>
              <th
                scope="col"
                className="text-left py-2 text-xs font-medium text-muted-foreground uppercase tracking-wider"
              >
                커버리지
              </th>
            </tr>
          </thead>
          <tbody className="divide-y divide-border">
            {categories.map((cat) => (
              <tr
                key={cat.code}
                className="hover:bg-muted/30 transition-colors"
              >
                <td className="py-2.5 pr-4">
                  <Badge variant="outline" className="font-mono">
                    {cat.code}
                  </Badge>
                </td>
                <td className="py-2.5 pr-4 text-foreground">{cat.name}</td>
                <td className="py-2.5 text-muted-foreground text-xs">
                  {cat.tier}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
