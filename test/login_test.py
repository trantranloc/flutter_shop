import unittest
import os
from appium import webdriver
from appium.webdriver.common.appiumby import AppiumBy
from appium.options.android import UiAutomator2Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, NoSuchElementException
from openpyxl import Workbook, load_workbook
import subprocess
import time

# Test data
TEST_DATA = {
    "TC_LOGIN_01": {
        "description": "Verify login with valid username and password (including uppercase, special character, and number)",
        "email": "user@example.com",
        "password": "Pass@123",
        "expected": "home_screen"
    },
    "TC_LOGIN_02": {
        "description": "Verify login with a non-existent username",
        "email": "wronguser@example.com",
        "password": "Pass@123",
        "expected": "error:Invalid username or password"
    },
    "TC_LOGIN_03": {
        "description": "Verify login with a password missing an uppercase letter",
        "email": "user@example.com",
        "password": "pass@123",
        "expected": "error:Password must contain at least one uppercase letter!"
    },
    "TC_LOGIN_04": {
        "description": "Verify login with a password missing a special character",
        "email": "user@example.com",
        "password": "Pass123",
        "expected": "error:Password must contain at least one special character!"
    },
    "TC_LOGIN_05": {
        "description": "Verify login with a password missing a number",
        "email": "user@example.com",
        "password": "Pass@abc",
        "expected": "error:Password must contain at least one number!"
    },
    "TC_LOGIN_06": {
        "description": "Verify login with an empty username field",
        "email": "",
        "password": "Pass@123",
        "expected": "error:Email cannot be empty!"
    },
    "TC_LOGIN_07": {
        "description": "Verify login with an empty password field",
        "email": "user@example.com",
        "password": "",
        "expected": "error:Password cannot be empty!"
    },
    "TC_LOGIN_08": {
        "description": "Verify login with both username and password fields empty",
        "email": "",
        "password": "",
        "expected": "error:Email cannot be empty!"
    },
    "TC_LOGIN_09": {
        "description": "Verify security against SQL injection input",
        "email": "' OR '1'='1",
        "password": "' OR '1'='1",
        "expected": "error:Invalid input"
    },
    "TC_LOGIN_10": {
        "description": "Verify login with special characters in the username",
        "email": "user@#$%@example.com",
        "password": "Pass@123",
        "expected": "error:Invalid email format!"
    },
    "TC_LOGIN_11": {
        "description": "Verify login with a username exceeding the maximum length",
        "email": "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz@example.com",
        "password": "Pass@123",
        "expected": "error:Email is too long!"
    },
    "TC_LOGIN_12": {
        "description": "Verify login with a password exceeding the maximum length",
        "email": "user@example.com",
        "password": "Pass@123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789",
        "expected": "error:Password is too long!"
    }
}

# Đường dẫn file Excel
output_dir = "output"
file_path = os.path.join(output_dir, "test_results5.xlsx")
results = []  # Lưu trữ kết quả tạm thời

# Tạo thư mục output nếu chưa có
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

# Nếu file không tồn tại -> tạo mới
if not os.path.exists(file_path):
    wb = Workbook()
    ws = wb.active
    ws.append(["Test Case", "Description", "Result", "Status", "Note"])
    wb.save(file_path)

class TestLoginAppium(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        """Khởi tạo kết nối Appium"""
        print("🔗 Connecting to Appium...")
        
        # Kiểm tra thiết bị Android
        try:
            devices = subprocess.check_output("adb devices", shell=True).decode()
            if "192.168.154.101:5555" not in devices:
                raise Exception("Emulator-5554 not found. Please start the emulator.")
        except subprocess.CalledProcessError:
            raise Exception("Error running adb. Ensure Android SDK is installed and adb is in PATH.")

        # Cấu hình Appium
        options = UiAutomator2Options()
        options.platform_name = "Android"
        options.device_name = "MyAndroidDevice"
        options.udid = "192.168.154.101:5555"
        options.app_package = "com.example.flutter_shop"
        options.app_activity = "com.example.flutter_shop.MainActivity"
        options.automation_name = "UiAutomator2"
        options.no_reset = False

        # Thử kết nối với retry
        max_attempts = 3
        for attempt in range(max_attempts):
            try:
                cls.driver = webdriver.Remote("http://localhost:4723", options=options)
                cls.wait = WebDriverWait(cls.driver, 60)
                print("✅ Connected successfully!")
                break
            except Exception as e:
                print(f"⚠️ Appium connection error (attempt {attempt + 1}/{max_attempts}): {str(e)}")
                if attempt == max_attempts - 1:
                    raise Exception("Failed to connect to Appium after multiple attempts.")
                time.sleep(2) 

    @classmethod
    def tearDownClass(cls):
        """Đóng kết nối Appium và lưu kết quả"""
        cls.driver.quit()
        print("🔴 Disconnected!")
        wb = load_workbook(file_path)
        ws = wb.active
        for result in results:
            ws.append(result)
        wb.save(file_path)
        print(f"📝 Results saved to {file_path}")

    def login(self, email, password):
        """Hàm thực hiện đăng nhập"""
        try:
            print(f"🔍 Logging in with Email: {email} / Password: {password}")
            email_field = self.wait.until(EC.visibility_of_element_located(
                (AppiumBy.XPATH, "//android.widget.EditText[@index='1']")
            ))
            email_field.click()
            email_field.clear()
            email_field.send_keys(email)

            pass_field = self.wait.until(EC.visibility_of_element_located(
                (AppiumBy.XPATH, "//android.widget.EditText[@index='2']")
            ))
            pass_field.click()
            pass_field.clear()
            pass_field.send_keys(password)

            login_button = self.wait.until(EC.element_to_be_clickable(
                (AppiumBy.XPATH, "//android.widget.Button[@content-desc='Login']")
            ))
            login_button.click()
            print("🖱️ Clicked Login button!")
            
            # Wait a moment for navigation to complete
            time.sleep(10)
            
            # Check if we successfully navigated to the home screen
            if self.is_home_screen():
                print("✅ Login successful - redirected to home screen")
                return None
            else:
                print("❌ Login failed - not redirected to home screen")
                return "Failed to redirect to home screen after login"
                
        except TimeoutException as e:
            return f"Error: Element not found - {str(e)}"
        except Exception as e:
            return f"Unknown error: {str(e)}"

    def is_home_screen(self):
        """Check if we're on the home screen by detecting unique UI elements"""
        try:
            # Look for common elements on the home screen
            elements_to_check = [
                "//android.widget.TextView[contains(@text, \"LIRIS\")]",  # Partial app title
                "//android.widget.TextView[@text='New Arrival Items']",   # Section title
                "//android.view.ViewGroup[contains(@resource-id, 'carousel')]"  # Carousel container
            ]
            
            for xpath in elements_to_check:
                try:
                    self.driver.find_element(by=AppiumBy.XPATH, value=xpath)
                    print(f"🏠 Detected home screen via element: {xpath}")
                    return True
                except NoSuchElementException:
                    continue
                    
            # Also check if we're definitely not on the login screen anymore
            try:
                # Look for login elements
                self.driver.find_element(by=AppiumBy.XPATH, value="//android.widget.EditText[@index='1']")
                print("⚠️ Still on login screen")
                return False
            except NoSuchElementException:
                # If we can't find login elements and we're in the app, we're probably on home screen
                print("🏠 Detected home screen (not on login screen)")
                return True
                
        except Exception as e:
            print(f"❓ Error detecting screen: {str(e)}")
            return False
    
    def logout(self):
        """Hàm đăng xuất với phương pháp khác vì nút Profile bị ẩn"""
        print("🔙 Attempting to log out using alternative method...")
        try:
            # Option 1: Back to login screen using Android back key
            self.driver.press_keycode(4)  # Android back key
            print("📱 Pressed Android back key")
            time.sleep(1)
            
            # Option 2: If back doesn't work, try launching the logout activity directly
            if not self.is_login_screen():
                self.driver.execute_script('mobile: deepLink', {
                    'url': 'flutter_shop://logout',
                    'package': 'com.example.flutter_shop'
                })
                print("🔗 Attempted deep link to logout screen")
                time.sleep(1)
        except Exception as e:
            print(f"⚠️ Navigation attempt failed: {str(e)}")
            
        # Check if we're back at the login screen
        if self.is_login_screen():
            print("✅ Logout successful - returned to login screen")
            return True
        else:
            # Final fallback: Restart the app (simulate a fresh start)
            print("⚠️ Could not navigate to login screen, restarting app")
            self.driver.terminate_app('com.example.flutter_shop')
            time.sleep(1)
            self.driver.activate_app('com.example.flutter_shop')
            time.sleep(2)
            
            if self.is_login_screen():
                print("✅ App restart successful - now at login screen")
                return True
            else:
                print("❌ Could not return to login screen even after app restart")
                return False
            
    def is_login_screen(self):
        """Check if we're on the login screen"""
        try:
            # Look for login input fields
            self.wait.until(EC.visibility_of_element_located(
                (AppiumBy.XPATH, "//android.widget.EditText[@index='1']")
            ))
            print("🔑 Login screen detected")
            return True
        except TimeoutException:
            print("❓ Not on login screen")
            return False
    def is_error_message_displayed(self, expected_message):
        """Kiểm tra thông báo lỗi"""
        try:
            self.wait.until(EC.visibility_of_element_located(
                (AppiumBy.XPATH, f"//android.widget.TextView[@text='{expected_message}']")
            ))
            print(f"⚠️ Error message found: '{expected_message}'")
            return True
        except TimeoutException:
            print(f"❌ Error message not found: '{expected_message}'")
            return False

    def run_test(self, test_id):
        """Hàm chạy test case"""
        data = TEST_DATA[test_id]
        print(f"\n📋 Running test {test_id}: {data['description']}")
        
        error = self.login(data["email"], data["password"])
        expected = data["expected"]
        
        if expected == "home_screen":
            # For positive test cases where we expect successful login
            if error is None and self.is_home_screen():
                result = True
                status = "Pass"
                note = "Successfully logged in and redirected to home screen"
                print("✅ Test PASS: Login successful")
                
                # Important: Logout for the next test
                logout_success = self.logout()
                if not logout_success:
                    note += " | Warning: Logout failed, may affect next test"
                    print("⚠️ Warning: Logout failed, may affect next test")
            else:
                result = False
                status = "Fail"
                note = error if error else "Failed to reach home screen"
                print(f"❌ Test FAIL: {note}")
        else:
            # For negative test cases where we expect an error message
            error_msg = expected.split("error:")[1]
            result = self.is_error_message_displayed(error_msg)
            status = "Pass" if result else "Fail"
            note = f"Expected error shown: '{error_msg}'" if result else f"Error message not displayed: '{error_msg}'"
            print(f"{'✅ Test PASS' if result else '❌ Test FAIL'}: {note}")

        results.append([test_id, data["description"], result, status, note])
        print(f"📊 Recorded result for {test_id}: {status}")

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

    def test_TC_LOGIN_12(self):
        self.run_test("TC_LOGIN_12")

if __name__ == "__main__":
    unittest.main()