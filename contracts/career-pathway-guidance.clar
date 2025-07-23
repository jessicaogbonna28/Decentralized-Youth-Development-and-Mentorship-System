;; Career Pathway Guidance Contract
;; Helps youth explore and prepare for career opportunities

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u500))
(define-constant ERR-NOT-FOUND (err u501))
(define-constant ERR-INVALID-INPUT (err u502))
(define-constant ERR-ALREADY-EXISTS (err u503))
(define-constant ERR-INVALID-SCORE (err u504))
(define-constant ERR-APPLICATION-EXISTS (err u505))

;; Data Variables
(define-data-var next-career-id uint u1)
(define-data-var next-opportunity-id uint u1)
(define-data-var next-application-id uint u1)
(define-data-var next-plan-id uint u1)

;; Data Maps
(define-map career-paths
  { career-id: uint }
  {
    title: (string-ascii 100),
    description: (string-ascii 500),
    industry: (string-ascii 50),
    required-skills: (string-ascii 400),
    education-requirements: (string-ascii 300),
    average-salary: uint,
    growth-outlook: (string-ascii 100),
    creation-date: uint
  }
)

(define-map job-opportunities
  { opportunity-id: uint }
  {
    title: (string-ascii 100),
    company-hash: (buff 32),
    description: (string-ascii 500),
    requirements: (string-ascii 400),
    salary-range: (string-ascii 50),
    location: (string-ascii 100),
    application-deadline: uint,
    status: (string-ascii 20),
    posting-date: uint
  }
)

(define-map career-assessments
  { youth-id: uint }
  {
    interests: (string-ascii 300),
    strengths: (string-ascii 300),
    preferred-work-environment: (string-ascii 200),
    career-goals: (string-ascii 400),
    assessment-date: uint,
    recommended-careers: (string-ascii 500)
  }
)

(define-map development-plans
  { plan-id: uint }
  {
    youth-id: uint,
    career-id: uint,
    short-term-goals: (string-ascii 400),
    long-term-goals: (string-ascii 400),
    skill-gaps: (string-ascii 300),
    action-steps: (string-ascii 500),
    target-completion: uint,
    creation-date: uint,
    status: (string-ascii 20)
  }
)

(define-map job-applications
  { application-id: uint }
  {
    youth-id: uint,
    opportunity-id: uint,
    application-date: uint,
    status: (string-ascii 20),
    cover-letter-hash: (buff 32),
    resume-hash: (buff 32),
    follow-up-date: uint
  }
)

(define-map youth-applications
  { youth-id: uint, opportunity-id: uint }
  { application-id: uint }
)

(define-map skill-certifications
  { youth-id: uint, skill-name: (string-ascii 100) }
  {
    certification-level: (string-ascii 50),
    issuing-organization: (string-ascii 100),
    issue-date: uint,
    expiry-date: uint,
    verification-hash: (buff 32)
  }
)

;; Create Career Path
(define-public (create-career-path
  (title (string-ascii 100))
  (description (string-ascii 500))
  (industry (string-ascii 50))
  (required-skills (string-ascii 400))
  (education-requirements (string-ascii 300))
  (average-salary uint)
  (growth-outlook (string-ascii 100)))
  (let
    (
      (career-id (var-get next-career-id))
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)

    (map-set career-paths
      { career-id: career-id }
      {
        title: title,
        description: description,
        industry: industry,
        required-skills: required-skills,
        education-requirements: education-requirements,
        average-salary: average-salary,
        growth-outlook: growth-outlook,
        creation-date: block-height
      }
    )

    (var-set next-career-id (+ career-id u1))
    (ok career-id)
  )
)

;; Post Job Opportunity
(define-public (post-job-opportunity
  (title (string-ascii 100))
  (company-hash (buff 32))
  (description (string-ascii 500))
  (requirements (string-ascii 400))
  (salary-range (string-ascii 50))
  (location (string-ascii 100))
  (application-deadline uint))
  (let
    (
      (opportunity-id (var-get next-opportunity-id))
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (> application-deadline block-height) ERR-INVALID-INPUT)

    (map-set job-opportunities
      { opportunity-id: opportunity-id }
      {
        title: title,
        company-hash: company-hash,
        description: description,
        requirements: requirements,
        salary-range: salary-range,
        location: location,
        application-deadline: application-deadline,
        status: "active",
        posting-date: block-height
      }
    )

    (var-set next-opportunity-id (+ opportunity-id u1))
    (ok opportunity-id)
  )
)

;; Conduct Career Assessment
(define-public (conduct-career-assessment
  (youth-id uint)
  (interests (string-ascii 300))
  (strengths (string-ascii 300))
  (preferred-work-environment (string-ascii 200))
  (career-goals (string-ascii 400))
  (recommended-careers (string-ascii 500)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)

    (map-set career-assessments
      { youth-id: youth-id }
      {
        interests: interests,
        strengths: strengths,
        preferred-work-environment: preferred-work-environment,
        career-goals: career-goals,
        assessment-date: block-height,
        recommended-careers: recommended-careers
      }
    )

    (ok true)
  )
)

;; Create Development Plan
(define-public (create-development-plan
  (youth-id uint)
  (career-id uint)
  (short-term-goals (string-ascii 400))
  (long-term-goals (string-ascii 400))
  (skill-gaps (string-ascii 300))
  (action-steps (string-ascii 500))
  (target-completion uint))
  (let
    (
      (plan-id (var-get next-plan-id))
      (career-exists (is-some (map-get? career-paths { career-id: career-id })))
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! career-exists ERR-NOT-FOUND)
    (asserts! (> target-completion block-height) ERR-INVALID-INPUT)

    (map-set development-plans
      { plan-id: plan-id }
      {
        youth-id: youth-id,
        career-id: career-id,
        short-term-goals: short-term-goals,
        long-term-goals: long-term-goals,
        skill-gaps: skill-gaps,
        action-steps: action-steps,
        target-completion: target-completion,
        creation-date: block-height,
        status: "active"
      }
    )

    (var-set next-plan-id (+ plan-id u1))
    (ok plan-id)
  )
)

;; Submit Job Application
(define-public (submit-job-application
  (youth-id uint)
  (opportunity-id uint)
  (cover-letter-hash (buff 32))
  (resume-hash (buff 32)))
  (let
    (
      (application-id (var-get next-application-id))
      (opportunity-data (unwrap! (map-get? job-opportunities { opportunity-id: opportunity-id }) ERR-NOT-FOUND))
      (existing-application (map-get? youth-applications { youth-id: youth-id, opportunity-id: opportunity-id }))
    )
    (asserts! (is-none existing-application) ERR-APPLICATION-EXISTS)
    (asserts! (< block-height (get application-deadline opportunity-data)) ERR-INVALID-INPUT)
    (asserts! (is-eq (get status opportunity-data) "active") ERR-INVALID-INPUT)

    (map-set job-applications
      { application-id: application-id }
      {
        youth-id: youth-id,
        opportunity-id: opportunity-id,
        application-date: block-height,
        status: "submitted",
        cover-letter-hash: cover-letter-hash,
        resume-hash: resume-hash,
        follow-up-date: u0
      }
    )

    (map-set youth-applications
      { youth-id: youth-id, opportunity-id: opportunity-id }
      { application-id: application-id }
    )

    (var-set next-application-id (+ application-id u1))
    (ok application-id)
  )
)

;; Award Skill Certification
(define-public (award-skill-certification
  (youth-id uint)
  (skill-name (string-ascii 100))
  (certification-level (string-ascii 50))
  (issuing-organization (string-ascii 100))
  (expiry-date uint)
  (verification-hash (buff 32)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (> expiry-date block-height) ERR-INVALID-INPUT)

    (map-set skill-certifications
      { youth-id: youth-id, skill-name: skill-name }
      {
        certification-level: certification-level,
        issuing-organization: issuing-organization,
        issue-date: block-height,
        expiry-date: expiry-date,
        verification-hash: verification-hash
      }
    )

    (ok true)
  )
)

;; Update Application Status
(define-public (update-application-status (application-id uint) (new-status (string-ascii 20)))
  (let
    (
      (application-data (unwrap! (map-get? job-applications { application-id: application-id }) ERR-NOT-FOUND))
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)

    (map-set job-applications
      { application-id: application-id }
      (merge application-data { status: new-status })
    )

    (ok true)
  )
)

;; Update Development Plan Status
(define-public (update-plan-status (plan-id uint) (new-status (string-ascii 20)))
  (let
    (
      (plan-data (unwrap! (map-get? development-plans { plan-id: plan-id }) ERR-NOT-FOUND))
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)

    (map-set development-plans
      { plan-id: plan-id }
      (merge plan-data { status: new-status })
    )

    (ok true)
  )
)

;; Read-only Functions
(define-read-only (get-career-path (career-id uint))
  (map-get? career-paths { career-id: career-id })
)

(define-read-only (get-job-opportunity (opportunity-id uint))
  (map-get? job-opportunities { opportunity-id: opportunity-id })
)

(define-read-only (get-career-assessment (youth-id uint))
  (map-get? career-assessments { youth-id: youth-id })
)

(define-read-only (get-development-plan (plan-id uint))
  (map-get? development-plans { plan-id: plan-id })
)

(define-read-only (get-job-application (application-id uint))
  (map-get? job-applications { application-id: application-id })
)

(define-read-only (get-youth-application (youth-id uint) (opportunity-id uint))
  (map-get? youth-applications { youth-id: youth-id, opportunity-id: opportunity-id })
)

(define-read-only (get-skill-certification (youth-id uint) (skill-name (string-ascii 100)))
  (map-get? skill-certifications { youth-id: youth-id, skill-name: skill-name })
)

(define-read-only (get-next-career-id)
  (var-get next-career-id)
)

(define-read-only (get-next-opportunity-id)
  (var-get next-opportunity-id)
)

(define-read-only (get-next-application-id)
  (var-get next-application-id)
)

(define-read-only (get-next-plan-id)
  (var-get next-plan-id)
)
