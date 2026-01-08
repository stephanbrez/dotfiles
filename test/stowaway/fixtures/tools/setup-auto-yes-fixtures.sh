# Auto-yes test fixtures setup script

SCRIPT_DIR="$(dirname "$0")"

echo "🔧 Creating auto-yes test fixtures..."

# Create auto-yes/single-package fixture
mkdir -p "$SCRIPT_DIR/fixtures/scenarios/auto-yes/single-package/source/test-pkg/.config/test-pkg"
cat >"$SCRIPT_DIR/fixtures/scenarios/auto-yes/single-package/source/test-pkg/.config/test-pkg/test.conf" <<'EOF'
# Test config file
EOF

mkdir -p "$SCRIPT_DIR/fixtures/scenarios/auto-yes/single-package/source/test-pkg/.config/test-pkg"
cat >"$SCRIPT_DIR/fixtures/scenarios/auto-yes/single-package/source/test-pkg/.config/test-pkg/test.sh" <<'EOF'
echo "TEST_VAR=1"
EOF

# Create target directory
mkdir -p "$SCRIPT_DIR/fixtures/scenarios/auto-yes/single-package/target"

echo "✅ Auto-yes single-package fixture created!"
