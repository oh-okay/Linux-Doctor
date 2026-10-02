import json
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "src"))
import linux_doctor


class LinuxDoctorTests(unittest.TestCase):
    def test_parse_line(self):
        finding = linux_doctor.parse_line("Storage\twarn\t/home\t87% used\tWorth keeping an eye on")
        self.assertEqual(finding.section, "Storage")
        self.assertEqual(finding.status, "warn")
        self.assertEqual(finding.value, "87% used")

    def test_invalid_line_is_ignored(self):
        self.assertIsNone(linux_doctor.parse_line("not structured"))

    def test_terminal_summary_counts_warnings(self):
        findings = [
            linux_doctor.Finding("System", "ok", "OS", "Linux"),
            linux_doctor.Finding("Storage", "warn", "/home", "87% used"),
        ]
        output = linux_doctor.render_terminal(findings)
        self.assertIn("1 thing worth looking at.", output)
        self.assertIn("/home: 87% used", output)

    def test_json_payload_shape(self):
        findings = [linux_doctor.Finding("System", "ok", "OS", "Linux")]
        payload = {"findings": [linux_doctor.asdict(item) for item in findings]}
        self.assertEqual(json.loads(json.dumps(payload))["findings"][0]["label"], "OS")


if __name__ == "__main__":
    unittest.main()
