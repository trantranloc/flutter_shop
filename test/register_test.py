import unittest
import time
from appium import webdriver
from appium.webdriver.common.appiumby import AppiumBy
from appium.options.android import UiAutomator2Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# Cấu hình Appium
options = UiAutomator2Options()
options.platform_name = "Android"
options.device_name = "MyAndroidDevice"
options.udid = "192.168.56.103:5555"
options.app_package = "com.example.flutter_shop"
options.app_activity = "com.example.flutter_shop.MainActivity"
options.automation_name = "UiAutomator2"
options.no_reset = True


class TestRegisterAppium(unittest.TestCase):
    def setUp(self):
        print("🔗 Đang kết nối Appium...")
        self.driver = webdriver.Remote("http://localhost:4723", options=options)
        self.wait = WebDriverWait(self.driver, 30)
        print("✅ Kết nối thành công!")

    def tearDown(self):
        self.driver.quit()
        print("🔴 Đã thoát kết nối!")

    def register(self, email, password, confirm_password):
        print(f"🔍 Đang đăng ký với email: {email}")

        # Nhập email
        email_field = self.wait.until(EC.visibility_of_element_located(
            (AppiumBy.XPATH, "//android.widget.EditText[@index='1']")
        ))
        email_field.click()
        email_field.clear()
        email_field.send_keys(email)

        # Nhập mật khẩu
        pass_field = self.wait.until(EC.visibility_of_element_located(
            (AppiumBy.XPATH, "//android.widget.EditText[@index='2']")
        ))
        pass_field.click()
        pass_field.clear()
        pass_field.send_keys(password)

        # Nhập lại mật khẩu
        confirm_pass_field = self.wait.until(EC.visibility_of_element_located(
            (AppiumBy.XPATH, "//android.widget.EditText[@index='3']")
        ))
        confirm_pass_field.click()
        confirm_pass_field.clear()
        confirm_pass_field.send_keys(confirm_password)

        # Nhấn nút đăng ký
        register_button = self.wait.until(EC.element_to_be_clickable(
            (AppiumBy.XPATH, "(//android.widget.Button)[1]")
        ))
        register_button.click()
        print("🖱️ Đã nhấn nút Đăng ký!")

        # Vuốt lên nếu thông báo không hiện
        self.driver.swipe(500, 1500, 500, 500, 1000)

        # **Thử lấy message và in ra**
        try:
            message = self.wait.until(EC.presence_of_element_located(
                (AppiumBy.XPATH, "//android.widget.TextView")
            )).text
            print(f"📢 Thông báo hiển thị: {message}")
        except:
            print("⚠️ Không tìm thấy thông báo nào!")

    def verify_message(self, expected_message):
        message = self.wait.until(EC.presence_of_element_located(
            (AppiumBy.XPATH, f"//android.widget.TextView[@text='{expected_message}']")
        )).text
        print(f"📢 Thông báo hệ thống: {message}")  # In ra thông báo
        self.assertEqual(message, expected_message)
        print(f"✅ Test Passed - {expected_message}")

    def test_register_success(self):
        """✅ Đăng ký thành công"""
        self.register("test@gmail.com", "Password123!", "Password123!")
        expected_message = "Đăng ký thành công!"
        print(f"🛠 Kiểm tra verify_message với nội dung: {expected_message}")
        self.verify_message(expected_message)

    def test_register_fail_existing_email(self):
        """❌ Kiểm thử email đã tồn tại"""
        self.register("test@gmail.com", "Password123!", "Password123!")
        expected_message = "Email đã tồn tại!"
        print(f"🛠 Kiểm tra verify_message với nội dung: {expected_message}")
        self.verify_message(expected_message)

    def test_register_fail_password_mismatch(self):
        """❌ Kiểm thử mật khẩu không khớp"""
        self.register("test2@gmail.com", "Password123!", "Password123")
        expected_message = "Mật khẩu không khớp!"
        print(f"🛠 Kiểm tra verify_message với nội dung: {expected_message}")
        self.verify_message(expected_message)

    def test_register_fail_empty_fields(self):
        """❌ Kiểm thử nhập trống"""
        self.register("", "", "")
        expected_message = "Vui lòng nhập đầy đủ thông tin!"
        print(f"🛠 Kiểm tra verify_message với nội dung: {expected_message}")
        self.verify_message(expected_message)

    def test_register_fail_short_password(self):
        """❌ Kiểm thử mật khẩu quá ngắn"""
        self.register("test3@gmail.com", "12", "12")
        expected_message = "Mật khẩu phải dài hơn 3 ký tự!"
        print(f"🛠 Kiểm tra verify_message với nội dung: {expected_message}")
        self.verify_message(expected_message)

    def test_register_fail_invalid_email(self):
        """❌ Kiểm thử email sai định dạng"""
        self.register("invalidemail", "Password123!", "Password123!")
        expected_message = "Email không hợp lệ!"
        print(f"🛠 Kiểm tra verify_message với nội dung: {expected_message}")
        self.verify_message(expected_message)

    def test_register_performance(self):
        """📊 Kiểm thử hiệu suất hệ thống"""
        start_time = time.time()
        self.register("test4@gmail.com", "Password123!", "Password123!")
        elapsed_time = time.time() - start_time
        print(f"⏳ Thời gian đăng ký: {elapsed_time:.2f} giây")
        self.assertLess(elapsed_time, 5, "⏳ Hệ thống phản hồi quá chậm!")
        print("✅ Test Passed - Hiệu suất đăng ký tốt!")

if __name__ == "__main__":
    unittest.main()
