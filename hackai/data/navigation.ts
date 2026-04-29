export interface NavItem {
  label: string;
  href: string;
  description?: string;
}

export const navItems = [
  {
    label: "홈",
    href: "/",
    description: "Madhat Labs 개요",
  },
  {
    label: "About",
    href: "/about",
    description: "연구 목적과 범위",
  },
  {
    label: "Architecture",
    href: "/architecture",
    description: "웹·클라우드·IAM 계층 구조",
  },
  {
    label: "Insights",
    href: "/insights",
    description: "AI 에이전트 보안 인사이트",
  },
  {
    label: "방어 원칙",
    href: "/defensive-principles",
    description: "11가지 방어 원칙",
  },
  {
    label: "FAQ",
    href: "/faq",
    description: "자주 묻는 질문",
  },
  {
    label: "Governance",
    href: "/governance",
    description: "윤리·법적 고지",
  },
  {
    label: "References",
    href: "/references",
    description: "참조 자료 목록",
  },
  {
    label: "Changelog",
    href: "/changelog",
    description: "변경 이력",
  },
] satisfies NavItem[];
