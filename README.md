### How to use it
- Set ENV var to `VERIFICATION_DOCUMENT_PATH`
- Create `cover.yml` with the following (see the sample) in the case directory:
    + name
    + dob
    + ssn (last 4)
    + address
    + phone
- Remove spaces in filenames
- run `ruby alan process --id TYPEFORM_ID` to combine all the docs and add a cover page

### To do / issues
- Stamp every page with PII/footer info
- No spaces in filenames or it breaks
- Refactor