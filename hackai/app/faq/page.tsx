import type { Metadata } from "next";
import { PageContainer, PageHeader } from "@/components/PageContainer";
import { FaqList } from "@/components/FaqList";
import { ErrorBoundary } from "@/components/ErrorBoundary";
import { faqItems } from "@/data/faq";
import { filterValid, isFaqItem } from "@/lib/guards";
import { logger } from "@/lib/debug";

export const metadata: Metadata = {
  title: "FAQ — Madhat Labs",
  description: "AI 에이전트 보안 연구에 대한 자주 묻는 질문과 답변",
};

export default function FaqPage() {
  const validItems = filterValid(faqItems, isFaqItem, "FaqItem");

  if (validItems.length !== faqItems.length) {
    logger.warn(
      "FaqPage",
      `${faqItems.length - validItems.length}개 FAQ 항목이 유효성 검사를 통과하지 못했습니다.`
    );
  }

  return (
    <PageContainer narrow>
      <PageHeader
        title="자주 묻는 질문"
        description={`이 저장소와 AI 에이전트 보안 연구에 대한 ${validItems.length}가지 질문과 답변입니다.`}
        badge="FAQ"
      />
      <ErrorBoundary namespace="FaqList">
        <FaqList items={validItems} />
      </ErrorBoundary>
    </PageContainer>
  );
}
