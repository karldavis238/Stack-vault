;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; StackVault - Secure Treasury Smart Contract
;; Language: Clarity
;; Author: Your Name / Team
;; Purpose: Manage deposits, withdrawals, and balances on-chain
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; -----------------------------
;; CONSTANTS & ERRORS
;; -----------------------------
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INSUFFICIENT_FUNDS (err u101))
(define-constant ERR_INVALID_AMOUNT (err u102))
(define-constant ERR_ALREADY_INITIALIZED (err u103))

;; -----------------------------
;; DATA VARIABLES
;; -----------------------------
;; Track total STX balance (for display only)
(define-data-var total-balance uint u0)

;; Track authorized withdrawers
(define-data-var authorized (list 10 principal) (list))

;; Track if contract has been initialized
(define-data-var initialized bool false)

;; -----------------------------
;; INITIALIZATION
;; -----------------------------
;; Called once by the contract deployer to set initial authorized signers
(define-public (initialize (initial-signers (list 10 principal)))
  (begin
    (asserts! (not (var-get initialized)) ERR_ALREADY_INITIALIZED)
    (asserts! (is-eq tx-sender contract-caller) ERR_UNAUTHORIZED)
    (var-set authorized initial-signers)
    (var-set initialized true)
    (ok true)
  )
)

;; -----------------------------
;; CORE FUNCTIONS
;; -----------------------------

;; Deposit STX into the vault
(define-public (deposit (amount uint))
  (begin
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (var-set total-balance (+ (var-get total-balance) amount))
    (ok (var-get total-balance))
  )
)

;; Withdraw STX (only if caller is authorized)
(define-public (withdraw (recipient principal) (amount uint))
  (begin
    (asserts! (is-authorized tx-sender) ERR_UNAUTHORIZED)
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)
    (asserts! (>= (var-get total-balance) amount) ERR_INSUFFICIENT_FUNDS)
    (try! (as-contract (stx-transfer? amount tx-sender recipient)))
    (var-set total-balance (- (var-get total-balance) amount))
    (ok (var-get total-balance))
  )
)

;; Add a new authorized withdrawer (only contract deployer can do this)
(define-public (add-authorized (new-signer principal))
  (let ((current-list (var-get authorized)))
    (asserts! (is-eq tx-sender contract-caller) ERR_UNAUTHORIZED)
    (asserts! (< (len current-list) u10) (err u104)) ;; Max 10 signers
    (var-set authorized (unwrap! (as-max-len? (append current-list new-signer) u10) (err u105)))
    (ok true)
  )
)

;; Remove an authorized withdrawer (only contract deployer can do this)
(define-public (remove-authorized (signer-to-remove principal))
  (begin
    (asserts! (is-eq tx-sender contract-caller) ERR_UNAUTHORIZED)
    (var-set authorized (filter is-not-target (var-get authorized)))
    (ok true)
  )
)

;; -----------------------------
;; PRIVATE HELPERS
;; -----------------------------

;; Check if an address is in the authorized list
(define-private (is-authorized (who principal))
  (is-some (index-of (var-get authorized) who))
)

;; Helper for filtering out a specific principal
(define-private (is-not-target (item principal))
  (not (is-eq item tx-sender))
)

;; -----------------------------
;; READ-ONLY FUNCTIONS
;; -----------------------------

;; View the current total balance of the vault
(define-read-only (get-total-balance)
  (ok (var-get total-balance))
)

;; View the list of authorized withdrawers
(define-read-only (get-authorized)
  (ok (var-get authorized))
)

;; Check if the contract has been initialized
(define-read-only (is-initialized)
  (ok (var-get initialized))
)

;; Check if a specific principal is authorized
(define-read-only (check-authorization (who principal))
  (ok (is-authorized who))
)
