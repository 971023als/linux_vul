import Link from "next/link";
import { PageContainer } from "@/components/PageContainer";

export default function NotFound() {
  return (
    <PageContainer narrow className="text-center">
      <p className="text-6xl font-bold text-blue-500/30 font-mono" aria-hidden="true">
        404
      </p>
      <h1 className="mt-4 text-2xl font-bold text-foreground">페이지를 찾을 수 없습니다</h1>
      <p className="mt-2 text-sm text-muted-foreground">
        요청하신 페이지가 존재하지 않거나 이동되었습니다.
      </p>
      <div className="mt-6">
        <Link
          href="/"
          className="inline-flex items-center justify-center rounded-lg bg-blue-600 px-5 py-2.5 text-sm font-medium text-white hover:bg-blue-700 transition-colors"
        >
          홈으로 돌아가기
        </Link>
      </div>
    </PageContainer>
  );
}
