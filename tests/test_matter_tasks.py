from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

from judicex_memory_os.store import LegalMemoryStore


class MatterTaskTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tempdir = tempfile.TemporaryDirectory()
        self.addCleanup(self.tempdir.cleanup)
        self.store = LegalMemoryStore(Path(self.tempdir.name) / "memory.db")
        self.addCleanup(self.store.close)
        self.matter = self.store.create_matter(
            "پرونده آزمایشی",
            client_name="موکل",
            area="خانواده",
        )

    def test_create_list_complete_and_delete_deadline(self) -> None:
        task = self.store.create_matter_task(
            self.matter["id"],
            "ثبت لایحه تجدیدنظرخواهی",
            description="مهلت قانونی پرونده",
            task_type="deadline",
            due_date="2026-12-10",
            priority="urgent",
        )

        self.assertEqual(task["task_type"], "deadline")
        self.assertEqual(task["due_date"], "2026-12-10")
        self.assertEqual(task["priority"], "urgent")
        self.assertEqual(task["status"], "open")
        self.assertEqual(len(self.store.list_matter_tasks(matter_id=self.matter["id"])), 1)

        completed = self.store.update_matter_task(task["id"], status="done")
        self.assertEqual(completed["status"], "done")
        self.assertTrue(completed["completed_at"])

        reopened = self.store.update_matter_task(task["id"], status="open")
        self.assertEqual(reopened["status"], "open")
        self.assertEqual(reopened["completed_at"], "")

        self.assertTrue(self.store.delete_matter_task(task["id"]))
        self.assertEqual(self.store.list_matter_tasks(matter_id=self.matter["id"]), [])

    def test_reject_invalid_due_date_and_unknown_matter(self) -> None:
        with self.assertRaises(ValueError):
            self.store.create_matter_task(
                self.matter["id"],
                "مهلت نامعتبر",
                due_date="10/12/2026",
            )
        with self.assertRaises(ValueError):
            self.store.create_matter_task("missing-matter", "اقدام")

    def test_tasks_are_removed_when_matter_is_deleted(self) -> None:
        self.store.create_matter_task(self.matter["id"], "جلسه دادگاه", task_type="hearing")
        self.assertTrue(self.store.delete_matter(self.matter["id"]))
        self.assertEqual(self.store.list_matter_tasks(), [])


if __name__ == "__main__":
    unittest.main()
