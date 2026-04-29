import Link from "next/link";
import { siteConfig } from "@/lib/site";

export function Footer() {
  const year = new Date().getFullYear();

  return (
    <footer className="border-t border-border bg-muted/30 mt-16">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8 py-8">
        <div className="flex flex-col sm:flex-row items-center justify-between gap-4">
          <div className="flex items-center gap-2 text-sm text-muted-foreground">
            <span className="text-blue-500" aria-hidden="true">◈</span>
            <span>{siteConfig.name}</span>
            <span aria-hidden="true">·</span>
            <span>방어형 보안 연구</span>
          </div>

          <div className="flex items-center gap-4 text-xs text-muted-foreground">
            <Link
              href="/governance"
              className="hover:text-foreground transition-colors"
            >
              거버넌스
            </Link>
            <Link
              href="/changelog"
              className="hover:text-foreground transition-colors"
            >
              Changelog
            </Link>
            <a
              href={siteConfig.links.github}
              target="_blank"
              rel="noopener noreferrer"
              className="hover:text-foreground transition-colors"
              aria-label="GitHub 저장소 (새 탭에서 열림)"
            >
              GitHub ↗
            </a>
          </div>
        </div>

        <div className="mt-4 text-xs text-muted-foreground text-center sm:text-left">
          <p>
            © {year} {siteConfig.author}. 소스코드 MIT, 문서 CC BY 4.0.{" "}
            <Link href="/governance" className="underline hover:text-foreground">
              이용 약관 및 윤리 고지
            </Link>
          </p>
          <p className="mt-1">
            이 사이트의 모든 내용은 방어·교육 목적에 한정됩니다. 비인가 시스템
            공격에 활용하는 것은 금지됩니다.
          </p>
        </div>
      </div>
    </footer>
  );
}
