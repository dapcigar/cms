import { test, expect } from '@playwright/test';

// Basic test for the Button component
// Assumes dev server is running at http://localhost:5173 (Vite default)
test.describe('Button.vue', () => {
  test('should render and respond to click', async ({ page }) => {
    await page.goto('http://localhost:5173');
    // Adjust selector as needed for your Button usage
    const button = page.locator('button');
    await expect(button).toHaveCount(1);
    await button.click();
    // Add more assertions here if your button has click effects
  });
});
