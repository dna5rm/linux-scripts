# Helper to manage ansible-vault

function vault_edit () {
    ansible-vault edit "${HOME}/.${USER:-loginrc}.vault" --vault-password-file "${TMPDIR}/.vault"
}

function vault_view () {
    ansible-vault view "${HOME}/.${USER:-loginrc}.vault" --vault-password-file "${TMPDIR}/.vault"
}
