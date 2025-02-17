import { expect, test } from '@playwright/test';
import { Page } from 'playwright';

import { startAppWithMocking } from './mocked-utils';

let page: Page;

test.beforeAll(async () => {
  ({ page } = await startAppWithMocking());
});

test.afterAll(async () => {
  await page.close();
});

test('Validate title', async () => {
  const title = await page.title();
  expect(title).toBe('Mullvad VPN');
  await expect(page.locator('header')).toBeVisible();
});
