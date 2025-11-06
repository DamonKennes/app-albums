;;;;;;;;;;;;;;;;;;;
;;; delta messenger
(in-package :delta-messenger)

;; (push (make-instance 'delta-logging-handler) *delta-handlers*) ;; enable if delta messages should be logged on terminal
(add-delta-messenger "http://delta-notifier/")
(setf *log-delta-messenger-message-bus-processing* nil) ;; set to t for extra messages for debugging delta messenger

;;;;;;;;;;;;;;;;;
;;; configuration
(in-package :client)
(setf *log-sparql-query-roundtrip* nil) ; change nil to t for logging requests to virtuoso (and the response)
(setf *backend* "http://triplestore:8890/sparql")

(in-package :server)
(setf *log-incoming-requests-p* nil) ; change nil to t for logging all incoming requests

;;;;;;;;;;;;;;;;
;;; prefix types
(in-package :type-cache)

(add-type-for-prefix "http://mu.semte.ch/sessions/" "http://mu.semte.ch/vocabularies/session/Session") ; each session URI will be handled for updates as if it had this mussession:Session type

;;;;;;;;;;;;;;;;;
;;; access rights

(in-package :acl)

;; these three reset the configuration, they are likely not necessary
(defparameter *access-specifications* nil)
(defparameter *graphs* nil)
(defparameter *rights* nil)

;; Prefixes used in the constraints below (not in the SPARQL queries)
(define-prefixes
  ;; Core
  :mu "http://mu.semte.ch/vocabularies/core/"
  :session "http://mu.semte.ch/vocabularies/session/"
  :ext "http://mu.semte.ch/vocabularies/ext/"
  :foaf "http://xmlns.com/foaf/0.1/"
  :schema "http://schema.org/"

  ;; Custom prefix URIs here, prefix casing is ignored
  )


;;;;;;;;;
;; Graphs
;;
;; These are the graph specifications known in the system.  No
;; guarantees are given as to what content is readable from a graph.  If
;; two graphs are nearly identitacl and have the same name, perhaps the
;; specifications can be folded too.  This could help when building
;; indexes.

(define-graph public ("http://mu.semte.ch/graphs/public")
  ("schema:Album" -> _)
  ("schema:MusicGroup" -> _)
  ("foaf:Person" -> _)
  ("foaf:OnlineAccount" -> _))

(define-graph private ("http://mu.semte.ch/graphs/private")
  ("schema:Review" -> _))

;; Example:
;; (define-graph company ("http://mu.semte.ch/graphs/companies/")
;;   ("foaf:OnlineAccount"
;;    -> "foaf:accountName"
;;    -> "foaf:accountServiceHomepage")
;;   ("foaf:Group"
;;    -> "foaf:name"
;;    -> "foaf:member"))


;;;;;;;;;;;;;
;; User roles

(supply-allowed-group "public")

(supply-allowed-group "authenticated"
  :query "PREFIX session: <http://mu.semte.ch/vocabularies/session/>
          PREFIX mu: <http://mu.semte.ch/vocabularies/core/>
          PREFIX foaf: <http://xmlns.com/foaf/0.1/>
          SELECT ?uuid WHERE {
            <SESSION_ID> session:account/^foaf:account/mu:uuid ?uuid .
          }"
  )

(grant (read write)
       :to-graph public
       :for-allowed-group "public")

(grant (read write)
       :to-graph private
       :for-allowed-group "authenticated")

;;(grant (read write)
;;       :to-graph accounts
;;       :for-allowed-group "public")

;;(grant (read write)
 ;;      :to-graph users
;;       :for-allowed-group "public")

;; example:

;; (supply-allowed-group "company"
;;   :query "PREFIX ext: <http://mu.semte.ch/vocabularies/ext/>
;;           SELECT DISTINCT ?uuid WHERE {
;;             <SESSION_ID ext:belongsToCompany/mu:uuid ?uuid
;;           }"
;;   :parameters ("uuid"))

;; (grant (read write)
;;        :to company
;;        :for "company")
