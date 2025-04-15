import unittest
import os
from appium import webdriver
from appium.webdriver.common.appiumby import AppiumBy
from appium.options.android import UiAutomator2Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoSuchElementException
from openpyxl import Workbook, load_workbook
import time
import concurrent.futures

# Test data
TEST_DATA = {
    "TC_LOGIN_01": {
        "description": "Verify login with a non-existent username",
        "email": "wronguser@example.com",
        "password": "Pass@123",
        "expected": "error:Invalid username or password"
    },
    "TC_LOGIN_02": {
        "description": "Verify login with a password missing an uppercase letter",
        "email": "user@example.com",
        "password": "pass@123",
        "expected": "error:Password must contain at least one uppercase letter!"
    },
    "TC_LOGIN_03": {
        "description": "Verify login with a password missing a special character",
        "email": "user@example.com",
        "password": "Pass123",
        "expected": "error:Password must contain at least one special character!"
    },
    "TC_LOGIN_04": {
        "description": "Verify login with a password missing a number",
        "email": "user@example.com",
        "password": "Pass@abc",
        "expected": "error:Password must contain at least one number!"
    },
    "TC_LOGIN_05": {
        "description": "Verify login with an empty username field",
        "email": "",
        "password": "Pass@123",
        "expected": "error:Email cannot be empty!"
    },
    "TC_LOGIN_06": {
        "description": "Verify login with an empty password field",
        "email": "user@example.com",
        "password": "",
        "expected": "error:Password cannot be empty!"
    },
    "TC_LOGIN_07": {
        "description": "Verify login with both username and password fields empty",
        "email": "",
        "password": "",
        "expected": "error:Email cannot be empty!"
    },
    "TC_LOGIN_08": {
        "description": "Verify login with special characters in the username",
        "email": "user@#$%@example.com",
        "password": "Pass@123",
        "expected": "error:Invalid email format!"
    },
    "TC_LOGIN_09": {
        "description": "Verify login with a username exceeding the maximum length",
        "email": "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz@example.com",
        "password": "Pass@123",
        "expected": "error:Email is too long!"
    },
    "TC_LOGIN_10": {
        "description": "Verify login with a password exceeding the maximum length",
        "email": "user@example.com",
        "password": "Pass@123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789",
        "expected": "error:Password is too long!"
    },
    "TC_LOGIN_11": {
        "description": "Verify login with valid username and password",
        "email": "user@example.com",
        "password": "Pass@123",
        "expected": "home_screen"
    },
}

# Đường dẫn file Excel
output_dir = "output"
file_path = os.path.join(output_dir, "test_results.xlsx")

# Tạo thư mục output nếu chưa có
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

# Nếu file không tồn tại -> tạo mới
if not os.path.exists(file_path):
    wb = Workbook()
    ws = wb.active
    ws.append(["Test Case", "Description", "Result", "Status", "Note", "Duration (ms)"])
    wb.save(file_path)

class TestLoginAppium(unittest.TestCase):
    results = []  # Biến lưu kết quả test toàn cục trong lớp

    @classmethod
    def setUpClass(cls):
        pass

    def setUp(self):
        options = UiAutomator2Options()
        options.platform_name = "Android"
        options.device_name = "MyAndroidDevice"
        options.udid = "b9fff218"
        options.app_package = "com.example.flutter_shop"
        options.app_activity = "com.example.flutter_shop.MainActivity"
        options.automation_name = "UiAutomator2"
        options.no_reset = True

        self.driver = webdriver.Remote("http://localhost:4723", options=options)
        self.wait = WebDriverWait(self.driver, 5)
        print(f"🔗 Driver created for test {self._testMethodName}")

    def tearDown(self):
        if hasattr(self, 'driver'):
            self.driver.quit()
            print(f"🔴 Driver closed for test {self._testMethodName}")

    @classmethod
    def tearDownClass(cls):
        wb = load_workbook(file_path)
        ws = wb.active
        for result in cls.results:
            ws.append(result)
        wb.save(file_path)
        print(f"📝 Results saved to {file_path}")

    def login(self, email, password):
        try:
            email_field = self.wait.until(EC.visibility_of_element_located(
                (AppiumBy.XPATH, "//android.widget.EditText[@index='1']")))
            email_field.click()
            email_field.clear()
            email_field.send_keys(email)

            pass_field = self.wait.until(EC.visibility_of_element_located(
                (AppiumBy.XPATH, "//android.widget.EditText[@index='2']")))
            pass_field.click()
            pass_field.clear()
            pass_field.send_keys(password)

            login_button = self.wait.until(EC.element_to_be_clickable(
                (AppiumBy.XPATH, "(//android.widget.Button)[1]")))
            login_button.click()
            return None
        except TimeoutException as e:
            return f"Error: Element not found - {str(e)}"
        except Exception as e:
            return f"Unknown error: {str(e)}"

    def is_home_screen(self):
        try:
            self.wait.until(EC.visibility_of_element_located(
                (AppiumBy.XPATH, "//android.view.View[@content-desc=\"LIRIS'FLORA\"]")))
            return True
        except TimeoutException:
            return False

    def run_test(self, test_id):
        start_time = time.time()
        data = TEST_DATA[test_id]
        print(f"\n📋 Running test {test_id}: {data['description']}")

        error = self.login(data["email"], data["password"])
        expected = data["expected"]

        if expected == "home_screen":
            if error is None and self.is_home_screen():
                result = True
                status = "Pass"
                note = "Successfully logged in and redirected to home screen"
                print(note)
                print(result,status)
            else:
                result = False
                status = "Fail"
                note = error if error else "Failed to reach home screen"
                print(note)
                print(result,status)
        else:
            if not self.is_home_screen():
                result = False
                status = "Fail"
                note = f"Login không thành công như dự kiến với {data['email']}/{data['password']}"
                print(note)
                print(result,status)
            else:
                result = True
                status = "Pass"
                note = "Đăng nhập sai nhưng vẫn vào được home screen"
                print(note)
                print(result,status)

        end_time = time.time()
        duration_ms = int((end_time - start_time) * 1000)

        result_row = [test_id, data["description"], result, status, note, duration_ms]
        TestLoginAppium.results.append(result_row)
        return result_row

    def test_TC_LOGIN_01(self):
        self.run_test("TC_LOGIN_01")
    def test_TC_LOGIN_02(self):
        self.run_test("TC_LOGIN_02")
    def test_TC_LOGIN_03(self):
        self.run_test("TC_LOGIN_03")
    def test_TC_LOGIN_04(self):
        self.run_test("TC_LOGIN_04")
    def test_TC_LOGIN_05(self):
        self.run_test("TC_LOGIN_05")
    def test_TC_LOGIN_06(self):
        self.run_test("TC_LOGIN_06")
    def test_TC_LOGIN_07(self):
        self.run_test("TC_LOGIN_07")
    def test_TC_LOGIN_08(self):
        self.run_test("TC_LOGIN_08")
    def test_TC_LOGIN_09(self):
        self.run_test("TC_LOGIN_09")
    def test_TC_LOGIN_10(self):
        self.run_test("TC_LOGIN_10")
    def test_TC_LOGIN_11(self):
        self.run_test("TC_LOGIN_11")

if __name__ == "__main__":
    unittest.main()