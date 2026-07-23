(() => {
    "use strict";

    const form = document.getElementById("reset-form");
    if (!form) {
        return;
    }

    const password = document.getElementById("password");
    const confirmation = document.getElementById("confirmation");
    const progress = document.getElementById("strength-progress");
    const strengthStatus = document.getElementById("strength-status");
    const confirmationStatus = document.getElementById("confirmation-status");
    const submitButton = document.getElementById("submit-button");

    const criteria = {
        length: value => value.length >= 12,
        uppercase: value => /[A-Z]/.test(value),
        lowercase: value => /[a-z]/.test(value),
        digit: value => /[0-9]/.test(value),
        special: value => /[!@#$%^&*(),.?":{}|<>]/.test(value)
    };

    const strengthLabels = [
        "Très faible",
        "Très faible",
        "Faible",
        "Moyen",
        "Fort",
        "Très fort"
    ];

    function evaluatePassword() {
        const value = password.value;
        let score = 0;

        Object.entries(criteria).forEach(([name, test]) => {
            const item = document.querySelector(`[data-criterion="${name}"]`);
            const icon = item.querySelector(".criterion-icon");
            const met = test(value);

            item.classList.toggle("met", met);
            item.setAttribute(
                "aria-label",
                `${item.dataset.label} : ${met ? "respecté" : "non respecté"}`
            );
            icon.textContent = met ? "✓" : "○";
            if (met) {
                score += 1;
            }
        });

        progress.value = score;
        progress.textContent = `${score} critères sur 5`;
        strengthStatus.value = `${strengthLabels[score]} — ${score}/5`;

        return score === 5;
    }

    function evaluateConfirmation() {
        if (confirmation.value.length === 0) {
            confirmationStatus.textContent = "";
            confirmationStatus.className = "field-status";
            return false;
        }

        const matches = password.value === confirmation.value;
        confirmationStatus.textContent = matches
            ? "Les mots de passe correspondent."
            : "Les mots de passe ne correspondent pas.";
        confirmationStatus.className = matches
            ? "field-status valid"
            : "field-status invalid";
        confirmation.setAttribute("aria-invalid", String(!matches));
        return matches;
    }

    function updateForm() {
        const passwordValid = evaluatePassword();
        const confirmationValid = evaluateConfirmation();
        submitButton.disabled = !(passwordValid && confirmationValid);
    }

    document.querySelectorAll("[data-toggle-password]").forEach(button => {
        button.addEventListener("click", () => {
            const input = document.getElementById(button.dataset.togglePassword);
            const showing = input.type === "text";

            input.type = showing ? "password" : "text";
            button.textContent = showing ? "Afficher" : "Masquer";
            button.setAttribute("aria-pressed", String(!showing));
            input.focus();
        });
    });

    password.addEventListener("input", updateForm);
    confirmation.addEventListener("input", updateForm);

    form.addEventListener("submit", event => {
        updateForm();
        if (submitButton.disabled) {
            event.preventDefault();
            if (!evaluatePassword()) {
                password.focus();
            } else {
                confirmation.focus();
            }
        }
    });

    updateForm();
})();
