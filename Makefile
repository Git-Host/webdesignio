# Configuration variables
# Options etc. go here.
# --
BROWSERIFY = browserify -t coffeeify -t jadeify
UGLIFY = uglifyjs
LESS = lessc --include-path=styles:.:public/components
CSSMIN = cssmin

# Runtime variables.  Load all dependencies.
WEBSITES = $(shell find websites -mindepth 2 -maxdepth 2 -wholename '*/public')
APPS = $(shell find . -mindepth 2 -maxdepth 2 -wholename '*/public')
TARGETS = $(WEBSITES:websites/%/public=public/%) $(APPS:./%/public=public/%)
SCRIPTS = $(shell find websites -maxdepth 3 -wholename '*/client/*.coffee')
STYLES = $(shell find websites -maxdepth 3 -wholename '*/styles/*.less')
APP_SCRIPTS = $(shell find . -maxdepth 3 -wholename '*/client/*.coffee')
APP_STYLES = $(shell find . -maxdepth 3 -wholename '*/styles/*.less')
SCRIPT_TARGETS = $(SCRIPTS:websites/%.coffee=public/%.js) \
	$(APP_SCRIPTS:./%.coffee=public/%.js)
STYLE_TARGETS = $(STYLES:websites/%.less=public/%.css) \
	$(APP_STYLES:./%.less=public/%.css)

public/%.js.ugz: %.coffee
	@mkdir -p $(dir $@)
	@$(BROWSERIFY) $< -o $@.unmin.js
	@$(UGLIFY) $@.unmin.js -c -m -o $@
	@rm $@.unmin.js

public/%.js.ugz: websites/%.coffee
	@mkdir -p $(dir $@)
	@$(BROWSERIFY) $< -o $@.unmin.js
	@$(UGLIFY) $@.unmin.js -c -m -o $@
	@rm $@.unmin.js

public/%.css.ugz: %.less
	@mkdir -p $(dir $@)
	@$(LESS) $< $@.unmin.css
	@$(CSSMIN) $@.unmin.css > $@
	@rm $@.unmin.css

public/%.css.ugz: websites/%.less
	@mkdir -p $(dir $@)
	@$(LESS) $< $@.unmin.css
	@$(CSSMIN) $@.unmin.css > $@
	@rm $@.unmin.css

public/%.gz: public/%.ugz
	@mv $< $(basename $<)
	@gzip -9 $(basename $<)

public/%.css: public/%.css.gz
	@mv $< $@

public/%.js: public/%.js.gz
	@mv $< $@

public/%: websites/%/public
	@rm -rf $@
	@cp -R $< $@

public/%: %/public
	@rm -rf $@
	@cp -R $< $@

# Run all required actions.
all: $(TARGETS) $(SCRIPT_TARGETS) $(STYLE_TARGETS)
