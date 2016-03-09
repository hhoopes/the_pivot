require "test_helper"

class UserCanCreateAnOrderTest < ActionDispatch::IntegrationTest
  test "logged_in user sees Stripe checkout process after checking out from cart" do
    skip
    user = create(:user)
    ApplicationController.any_instance.stubs(:current_user).returns(user)

    gif = create(:gif)

    visit gif_path(gif)
    click_link "Add to cart"
    visit "/cart"

    within "table" do
      click_on "Checkout"
    end

    assert_equal "/charges/new", current_path
    assert page.has_content?("Please provide a payment method to continue with your purchase.")
save_and_open_page
    click_link_or_button "Pay with Card"
    fill_in "email", with: "bob@example.com"
    fill_in "card_number", with: "4242 4242 4242 4242"
    fill_in "cc-exp", with: "1216"
    fill_in "cc-csc", with: "123"


    assert page.has_content? "order_#{user.orders.last.id}"
  end

  test "logged out user prompted to log in before checkout" do
    user = create(:user)
    gif = create(:gif)
    visit gif_path(gif)
    click_link "Add to cart"
    visit "/cart"
    within "table" do
      click_on "Checkout"
    end

    assert_equal "/login", current_path
    assert page.has_content? "Please login or create a new account before checking out."

    fill_in "Username", with: "#{user.username}"
    fill_in "Password", with: "#{user.password}"

    within ".login" do
      click_on "Login"
    end

    assert_equal "/dashboard", current_path
    assert page.has_content?("logged_in_as_#{user.username}")

    visit "/cart"
    within "table" do
      click_on "Checkout"
    end

      assert page.has_content? "order_#{user.orders.last.id}"
  end

  test "user can create multiple orders and view them" do
    user = create(:user)
    gif = create(:gif)
    gif2 = create(:gif)
    ApplicationController.any_instance.stubs(:current_user).returns(user)

    visit gif_path(gif)
    click_link "Add to cart"

    visit "/cart"

    within "table" do
      click_on "Checkout"
    end

    assert page.has_content? "order_#{user.orders.first.id}"

    visit gif_path(gif2)
    click_link "Add to cart"

    visit "/cart"

    within "table" do
      click_on "Checkout"
    end

    assert page.has_content? "order_#{user.orders.first.id}"
    assert page.has_content? "order_#{user.orders.last.id}"
  end
end
