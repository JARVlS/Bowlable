<template>
  <form @submit.prevent="register()" class="register-form">
    <h1>Registrieren</h1>
    <label class="register-form__input">
      <input type="text" v-model="registrationForm.username" required />
      <span>Username</span>
    </label>
    <label class="register-form__input">
      <input type="text" v-model="registrationForm.email" required />
      <span>E-Mail</span>
    </label>
    <label class="register-form__input">
      <input type="password" v-model="registrationForm.password" required />
      <span>Passwort</span>
    </label>
    <label class="register-form__input">
      <input type="password" v-model="repeatedPassword" required />
      <span>Passwort erneut eingeben</span>
    </label>
    <button type="submit" class="register-form__button">Registrieren</button>
  </form>
</template>

<script lang="ts" setup>
import { RegisterInput, useRegisterMutation } from "@app/graphql";
import { reactive, ref } from "vue";

const registrationForm = reactive<RegisterInput>({
  email: "",
  password: "",
  username: "",
});

const repeatedPassword = ref("");

const {
  data,
  error,
  fetching,
  executeMutation: registerMutation,
} = useRegisterMutation();

async function register() {
  if (!fetching.value) {
    await registerMutation(registrationForm);
  }
}

if (!import.meta.env.SSR) {
  var bubbles = [
  { top: "12vh", left: "17vw", delay: "0s", width: "13vw" },
  { top: "5vh", left: "7vw", delay: "1s", width: "8vw" },
  { top: "30vh", left: "11vw", delay: "2s", width: "10vw" },
  { top: "17vh", left: "86vw", delay: "1s", width: "16vw" },
  { top: "63vh", left: "12vw", delay: "1s", width: "12vw" },
  { top: "80vh", left: "175vw", delay: "0s", width: "14vw" },
  { top: "80vh", left: "90vw", delay: "1s", width: "13vw" },
  { top: "50vh", left: "70vw", delay: "2s", width: "15vw" },
  { top: "80vh", left: "90vw", delay: "1s", width: "13vw" },
];

bubbles.forEach((bubble) => {
  var b = document.createElement("div");
  b.className = "bubbles";
  b.style.top = bubble.top;
  b.style.left = bubble.left;
  b.style.animationDelay = bubble.delay;
  b.style.width = bubble.width;
  document.body.appendChild(b);
});
}

</script>


<style scoped lang="scss">
.register-form {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 2rem;
  width: 50vw;
  height: 80vh;
  min-width: max-content;
  min-height: fit-content;
  overflow-y: auto;
  margin-inline: auto;
  margin-top: 10vh;
  border-radius: 5px;
  padding: 2rem;
  background-color: var(--background-base-color);
  box-shadow: 0 0 15px var(--text-base-color);
  z-index: 10;
}

.register-form__input {
  position: relative;
  width: 70%;
}

.register-form__input span {
  position: absolute;
  top: 0.4rem;
  left: 0;
  font-size: 0.9rem;
  color: var(--text-base-color);
  transition: top 0.2s ease-in-out, font-size 0.2s ease-in-out;
}

.register-form__input input {
  width: 100%;
  padding: 0.5rem;
  border: none;
  border-bottom: 2px solid var(--text-base-color);
  outline: none;
}

.register-form__input input:focus + span,
.register-form__input input:valid + span {
  top: -1rem;
  font-size: 0.7rem;
}

.register-form__button {
  width: 70%;
  padding: 0.5rem;
  border: none;
  border-radius: 5px;
  background-color: #777;
  color: var(--background-base-color);
  font-weight: bold;
  cursor: not-allowed;
  font-size: large;
  transition: background-color 0.2s ease-in-out;
}

.register-form:valid .register-form__button {
  cursor: pointer;
  background-color: var(--text-base-color);
}

/* some playful design */

.bubbles {
  content: "";
  position: absolute;
  min-width: 5rem;
  aspect-ratio: 1/1;
  border-radius: 50%;
  box-shadow: 0 0 15px var(--text-base-color);
  background: linear-gradient(
    -45deg,
    var(--text-base-color),
    var(--background-base-color)
  );
  opacity: 0.3;
  filter: blur(1px);
  backdrop-filter: blur(2px);
  z-index: -1;
  // top: var(--top);
  // left: var(--left);
  // width: var(--width, 5vw);
  // animation-delay: var(--delay);
  animation: floating 5s ease-in-out infinite;
}

@keyframes floating {
  0% {
    transform: translateY(0px) translateX(0px);
  }
  50% {
    transform: translateY(15px) translateX(10px);
  }
  100% {
    transform: translateY(0px) translateX(0px);
  }
}
</style>
