cat > scripts/deploy.js << 'EOF'
async function main() {
  console.log("🚀 شروع استقرار قرارداد استیبل‌کوین...");
  
  // گرفتن حساب‌های موجود
  const [deployer] = await ethers.getSigners();
  console.log("آدرس استقرار دهنده:", deployer.address);
  console.log("موجودی استقرار دهنده:", (await deployer.getBalance()).toString());
  
  // استقرار قرارداد استیبل‌کوین
  const StableCoin = await ethers.getContractFactory("StableCoin");
  const stablecoin = await StableCoin.deploy("MyStableCoin", "MSC");
  
  await stablecoin.waitForDeployment();
  
  console.log("✅ قرارداد استیبل‌کوین مستقر شد!");
  console.log("آدرس قرارداد:", await stablecoin.getAddress());
  
  // اطلاعات اضافی
  const name = await stablecoin.name();
  const symbol = await stablecoin.symbol();
  const totalSupply = await stablecoin.totalSupply();
  
  console.log("نام توکن:", name);
  console.log("نماد توکن:", symbol);
  console.log("تامین کل:", totalSupply.toString());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ خطا:", error);
    process.exit(1);
  });
EOF
