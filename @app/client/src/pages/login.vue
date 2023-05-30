<template>
  <form @submit.prevent="login()" class="login">
    <label class="login__input">
      <input type="text" v-model="username" required />
      <span>Username</span>
    </label>
    <label class="login__input">
      <input type="password" v-model="password" required />
      <span>Password</span>
    </label>
    <button type="submit" class="login__button">Login</button>
  </form>
  <pre>{{ data }}</pre>
  <pre>{{ error }}</pre>
  <pre>{{ currentUserData }}</pre>
</template>

<script lang="ts" setup>
import { useCurrentUserQuery, useLoginMutation } from "@app/graphql";
import { ref, unref } from "vue";
import { useClientHandle } from "@urql/vue";

const username = ref("");
const password = ref("");

const { data: currentUserData } = useCurrentUserQuery({});

const { data, error, executeMutation: loginMutation } = useLoginMutation();

const client = useClientHandle();
async function login() {
  console.log("huhuhuhuhu");
  console.log(client);
  await loginMutation({
    username: unref(username),
    password: unref(password),
  });
}
</script>

<style scoped>
.login {
  height: 80%;
  width: 60%;
  margin-inline: auto;
  margin-top: 10%;
  display: flex;
  gap: 1rem;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  box-shadow: 0 0 15px black;
  border-radius: 5px;
}

.login__input {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  margin-bottom: 10px;
  position: relative;
}
.login__input input {
  width: 200px;
  height: 30px;
  padding: 0 0.5rem;
  border: none;
  border-bottom: 1px solid black;
  outline: none;
  background-color: transparent;
}
.login__input span {
  position: absolute;
  left: 0.5rem;
  color: rgba(0, 0, 0, 0.5);
  font-weight: bold;
  transition: transform 0.3s ease-out, font-size 0.3s ease, color 0.3s;
}

.login__input input:focus + span,
.login__input input:valid + span {
  transform: translateY(-1.5rem);
  font-size: 0.8rem;
  color: black;
}

.login__button {
  padding: 0.5rem 1rem;
  min-width: 50%;
  border: none;
  border-radius: 5px;
  background-color: #000;
  color: white;
  font-weight: bold;
  cursor: pointer;
}
</style>
