"""Deliberately bad code: a CUPID anti-fixture for testing the
``cupid-code-review`` skill's ability to surface real violations.

This file is **not production code**. It exists as a stable fixture
that a Layer 3 test feeds to the skill, expecting the skill to
identify the categories of failure documented in the scenario:

- Composable: instantiates dependencies in the constructor; cannot
  be used without dragging them in
- Unix philosophy: one class spans authentication, email, audit
  logging, password hashing, and analytics
- Predictable: methods named ``get_user`` perform side effects
  (audit-log writes, last-seen updates) that the name does not
  reveal
- Idiomatic: ``camelCase`` method names in a Python file, against
  PEP 8
- Domain-based: methods named for plumbing (``runSqlQuery``,
  ``flushBuffer``) rather than for the domain (``recordLogin``,
  ``expireSession``)

If the skill misses these — or worse, produces a generic CUPID
summary that does not reference any of the specific code below — the
test fails. The fixture's stability matters: changing it changes
what the test verifies, so edits should be deliberate and reviewed
together with the scenario file.
"""

import hashlib
import smtplib
import sqlite3
from datetime import datetime


class UserManager:
    """Anti-pattern: one class spanning many concerns."""

    def __init__(self):
        # Composable failure: hard-coded dependencies forced inside
        # the constructor. There is no way to use this class in a
        # test without a real database, an SMTP server, and a writable
        # log file.
        self.db = sqlite3.connect("users.db")
        self.smtp = smtplib.SMTP("smtp.example.com", 587)
        self.log_file = open("/var/log/users.log", "a")
        self.audit_buffer = []

    def get_user(self, userId):
        """Predictable failure: name says 'get' but the method writes
        an audit log entry, updates last-seen timestamps, and flushes
        a buffer. None of this is suggested by the method name.
        """
        # Domain-based failure: the method name describes the action
        # in plumbing terms, not domain terms.
        result = self.runSqlQuery(
            f"SELECT * FROM users WHERE id = {userId}"
        )
        # Unprovoked side-effects:
        self.audit_buffer.append(
            {"action": "read_user", "user": userId, "ts": datetime.utcnow()}
        )
        self.runSqlQuery(
            f"UPDATE users SET last_seen = NOW() WHERE id = {userId}"
        )
        if len(self.audit_buffer) > 100:
            self.flushBuffer()
        return result

    def runSqlQuery(self, sql):
        """Idiomatic failure: camelCase in a Python file. Domain-based
        failure: 'run a SQL query' is plumbing, not domain.
        """
        cursor = self.db.execute(sql)
        return cursor.fetchall()

    def flushBuffer(self):
        """Domain-based failure: 'flush the buffer' is plumbing
        terminology. The domain action is 'persist audit trail'.
        """
        for entry in self.audit_buffer:
            self.log_file.write(str(entry) + "\n")
        self.log_file.flush()
        self.audit_buffer.clear()

    def authenticate(self, userId, password):
        """Unix-philosophy failure: this single class authenticates,
        hashes passwords, sends emails, logs audits, and updates
        analytics. Five responsibilities in one method, fifteen in
        one class.
        """
        user = self.get_user(userId)
        if not user:
            self.smtp.sendmail(
                "system@example.com",
                "security@example.com",
                "Failed login attempt",
            )
            return False

        hashed = hashlib.md5(password.encode()).hexdigest()
        if hashed != user[2]:
            self.runSqlQuery(
                f"UPDATE users SET failed_logins = failed_logins + 1 "
                f"WHERE id = {userId}"
            )
            return False

        # Side-effect cascade hidden inside an authenticate() call:
        self.runSqlQuery(
            f"INSERT INTO analytics(user_id, event) "
            f"VALUES ({userId}, 'login')"
        )
        self.audit_buffer.append(
            {"action": "login", "user": userId, "ts": datetime.utcnow()}
        )
        if len(self.audit_buffer) > 100:
            self.flushBuffer()
        return True

    def emailUser(self, userId, subject, body):
        """Idiomatic failure: camelCase. Unix-philosophy failure:
        email delivery does not belong in a UserManager.
        """
        user = self.get_user(userId)
        self.smtp.sendmail(
            "noreply@example.com", user[1], f"Subject: {subject}\n\n{body}"
        )
