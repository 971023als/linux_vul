import Link from "next/link";
import { Badge } from "@/components/Badge";

export function Hero() {
  return (
    <section
      className="relative overflow-hidden border-b border-border bg-gradient-to-b from-muted/50 to-background"
      aria-labelledby="hero-heading"
    >
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8 py-16 sm:py-24">
        <div className="max-w-2xl">
          <div className="flex flex-wrap gap-2 mb-5">
            <Badge variant="outline">방어형 보안 연구</Badge>
            <Badge variant="outline">AI 에이전트</Badge>
            <Badge variant="outline">OWASP APTS</Badge>
          </div>

          <h1
            id="hero-heading"
            className="text-4xl font-bold tracking-tight text-foreground sm:text-5xl lg:text-6xl text-balance"
          >
            AI 에이전트의{" "}
            <span className="text-blue-500">공격 표면</span>을<br />
            방어 관점으로
          </h1>

          <p className="mt-5 text-lg text-muted-foreground leading-relaxed max-w-xl">
            Madhat Labs는 AI 에이전트 시스템의 보안 취약점을 연구하고, 방어팀과
            개발자가 더 안전한 시스템을 설계할 수 있도록 인사이트와 원칙을
            공개합니다.
          </p>

          <div className="mt-8 flex flex-wrap gap-3">
            <Link
              href="/insights"
              className="inline-flex items-center justify-center rounded-lg bg-blue-600 px-5 py-2.5 text-sm font-medium text-white hover:bg-blue-700 transition-colors focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-600"
            >
              인사이트 보기
            </Link>
            <Link
              href="/defensive-principles"
              className="inline-flex items-center justify-center rounded-lg border border-border bg-background px-5 py-2.5 text-sm font-medium text-foreground hover:bg-muted transition-colors"
            >
              방어 원칙 →
            </Link>
          </div>
        </div>

        {/* Decorative grid */}
        <div
          className="absolute right-0 top-0 -z-10 h-full w-1/2 opacity-[0.03] dark:opacity-[0.05]"
          aria-hidden="true"
        >
          <svg
            className="h-full w-full"
            viewBox="0 0 400 400"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <defs>
              <pattern
                id="grid"
                width="40"
                height="40"
                patternUnits="userSpaceOnUse"
              >
                <path
                  d="M 40 0 L 0 0 0 40"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="1"
                />
              </pattern>
            </defs>
            <rect width="400" height="400" fill="url(#grid)" />
          </svg>
        </div>
      </div>
    </section>
  );
}
