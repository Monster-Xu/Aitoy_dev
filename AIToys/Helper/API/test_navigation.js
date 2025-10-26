/**
 * 测试页面跳转的小程序代码
 * 请在小程序中运行这些代码来测试跳转功能
 */

// 测试跳转到首页
function testNavigateToHome() {
  console.log('=== 测试跳转到首页 ===');
  ty.extApiInvoke({
    api: 'navigateToNativePage',
    params: {
      path: 'home'
    },
    success: (res) => {
      console.log('✅ 跳转首页成功:', res.data);
      ty.showToast({
        title: '已跳转到首页',
        icon: 'success'
      });
    },
    fail: (err) => {
      console.log('❌ 跳转首页失败:', err);
      ty.showToast({
        title: `跳转失败: ${err.errorMsg}`,
        icon: 'none'
      });
    }
  });
}

// 测试跳转到我的页面
function testNavigateToProfile() {
  console.log('=== 测试跳转到我的页面 ===');
  ty.extApiInvoke({
    api: 'navigateToNativePage',
    params: {
      path: 'profile'
    },
    success: (res) => {
      console.log('✅ 跳转我的页面成功:', res.data);
      ty.showToast({
        title: '已跳转到我的页面',
        icon: 'success'
      });
    },
    fail: (err) => {
      console.log('❌ 跳转我的页面失败:', err);
      ty.showToast({
        title: `跳转失败: ${err.errorMsg}`,
        icon: 'none'
      });
    }
  });
}

// 测试跳转到第二个页面（索引1）
function testNavigateToSecondPage() {
  console.log('=== 测试跳转到第二个页面 ===');
  // 由于我们只支持 home 和 profile，这里我们可以临时修改代码来测试
  // 或者您可以在 iOS 代码中添加对索引 1 的支持
  
  ty.extApiInvoke({
    api: 'navigateToNativePage',
    params: {
      path: 'home' // 先跳转到首页，然后手动切换到其他页面观察
    },
    success: (res) => {
      console.log('✅ 跳转成功，请手动切换到第二个页面观察效果');
    },
    fail: (err) => {
      console.log('❌ 跳转失败:', err);
    }
  });
}

// 连续测试所有页面
function testAllPages() {
  console.log('=== 开始连续测试所有页面 ===');
  
  // 先跳转到首页
  setTimeout(() => {
    console.log('1. 跳转到首页...');
    testNavigateToHome();
  }, 1000);
  
  // 再跳转到我的页面
  setTimeout(() => {
    console.log('2. 跳转到我的页面...');
    testNavigateToProfile();
  }, 3000);
  
  // 再跳转回首页
  setTimeout(() => {
    console.log('3. 再次跳转到首页...');
    testNavigateToHome();
  }, 5000);
}

// 检查 API 可用性
function checkAPIAvailability() {
  console.log('=== 检查 API 可用性 ===');
  ty.extApiCanIUse({
    api: 'navigateToNativePage',
    success: (res) => {
      console.log('API 可用性检查结果:', res.result);
      if (res.result) {
        console.log('✅ navigateToNativePage API 可用');
        ty.showToast({
          title: 'API 可用',
          icon: 'success'
        });
      } else {
        console.log('❌ navigateToNativePage API 不可用');
        ty.showToast({
          title: 'API 不可用',
          icon: 'error'
        });
      }
    },
    fail: (err) => {
      console.log('❌ API 可用性检查失败:', err);
      ty.showToast({
        title: 'API 检查失败',
        icon: 'error'
      });
    }
  });
}

// 页面对象
Page({
  data: {
    title: '页面跳转测试'
  },

  onLoad() {
    console.log('测试页面加载完成');
    // 自动检查 API 可用性
    checkAPIAvailability();
  },

  // 按钮点击事件
  onHomeButtonTap() {
    testNavigateToHome();
  },

  onProfileButtonTap() {
    testNavigateToProfile();
  },

  onTestAllButtonTap() {
    testAllPages();
  },

  onCheckAPIButtonTap() {
    checkAPIAvailability();
  }
});

// 如果您想在控制台直接运行，可以使用以下命令：
console.log('可用的测试函数:');
console.log('- testNavigateToHome(): 测试跳转到首页');
console.log('- testNavigateToProfile(): 测试跳转到我的页面');
console.log('- testAllPages(): 连续测试所有页面');
console.log('- checkAPIAvailability(): 检查 API 可用性');

// 导出函数
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    testNavigateToHome,
    testNavigateToProfile,
    testAllPages,
    checkAPIAvailability
  };
}
